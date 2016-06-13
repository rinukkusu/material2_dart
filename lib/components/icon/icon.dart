import 'dart:html';
import 'dart:svg';
import 'package:angular2/core.dart';
import 'package:quiver/strings.dart';

import 'package:material2_dart/core/errors/error.dart';
import 'icon_registry.dart';
export 'icon_registry.dart';

/** Exception thrown when an invalid icon name is passed to an md-icon component. */
class MdIconInvalidNameError extends MdError {
  MdIconInvalidNameError(String iconName)
      : super('Invalid icon name: "$iconName"');
}

/**
 * Component to display an icon. It can be used in the following ways:
 * - Specify the svgSrc input to load an SVG icon from a URL. The SVG content is directly inlined
 *   as a child of the <md-icon> component, so that CSS styles can easily be applied to it.
 *   The URL is loaded via an XMLHttpRequest, so it must be on the same domain as the page or its
 *   server must be configured to allow cross-domain requests.
 *   Example:
 *     <md-icon svgSrc="assets/arrow.svg"></md-icon>
 *
 * - Specify the svgIcon input to load an SVG icon from a URL previously registered with the
 *   addSvgIcon, addSvgIconInNamespace, addSvgIconSet, or addSvgIconSetInNamespace methods of
 *   MdIconRegistry. If the svgIcon value contains a colon it is assumed to be in the format
 *   "[namespace]:[name]", if not the value will be the name of an icon in the default namespace.
 *   Examples:
 *     <md-icon svgIcon="left-arrow"></md-icon>
 *     <md-icon svgIcon="animals:cat"></md-icon>
 *
 * - Use a font ligature as an icon by putting the ligature text in the content of the <md-icon>
 *   component. By default the Material icons font is used as described at
 *   http://google.github.io/material-design-icons/#icon-font-for-the-web. You can specify an
 *   alternate font by setting the fontSet input to either the CSS class to apply to use the
 *   desired font, or to an alias previously registered with MdIconRegistry.registerFontClassAlias.
 *   Examples:
 *     <md-icon>home</md-icon>
 *     <md-icon fontSet="myfont">sun</md-icon>
 *
 * - Specify a font glyph to be included via CSS rules by setting the fontSet input to specify the
 *   font, and the fontIcon input to specify the icon. Typically the fontIcon will specify a
 *   CSS class which causes the glyph to be displayed via a :before selector, as in
 *   https://fortawesome.github.io/Font-Awesome/examples/
 *   Example:
 *     <md-icon fontSet="fa" fontIcon="alarm"></md-icon>
 */
@Component(
    template: '<ng-content></ng-content>',
    selector: 'md-icon',
    styleUrls: const ['icon.scss.css'],
    host: const {'role': 'img',},
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdIcon implements OnChanges, OnInit, AfterViewChecked {
  @Input()
  String svgSrc;
  @Input()
  String svgIcon;
  @Input()
  String fontSet;
  @Input()
  String fontIcon;
  @Input()
  String alt;

  @Input('aria-label')
  String hostAriaLabel = '';

  String _previousFontSetClass;
  String _previousFontIconClass;

  ElementRef _elementRef;
  Renderer _renderer;
  MdIconRegistry _mdIconRegistry;

  MdIcon(this._elementRef, this._renderer, this._mdIconRegistry);

  /**
   * Splits an svgIcon binding value into its icon set and icon name components.
   * Returns a 2-element array of [(icon set), (icon name)].
   * The separator for the two fields is ':'. If there is no separator, an empty
   * string is returned for the icon set and the entire value is returned for
   * the icon name. If the argument is falsy, returns an array of two empty strings.
   * Throws a MdIconInvalidNameError if the name contains two or more ':' separators.
   * Examples:
   *   'social:cake' -> ['social', 'cake']
   *   'penguin' -> ['', 'penguin']
   *   null -> ['', '']
   *   'a:b:c' -> (throws MdIconInvalidNameError)
   */
  List<String> _splitIconName(String iconName) {
    if (iconName == null) {
      return ['', ''];
    }
    final parts = iconName.split(':');
    switch (parts.length) {
      case 1:
        // Use default namespace.
        return ['', parts.first];
      case 2:
        return parts;
      default:
        throw new MdIconInvalidNameError(iconName);
    }
  }

  /** TODO: internal */
//  { [propertyName: string]: SimpleChange }
  ngOnChanges(changes) {
    final changedInputs = changes.keys;
    // Only update the inline SVG icon if the inputs changed, to avoid unnecessary DOM operations.
    if (changedInputs.indexOf('svgIcon') != -1 ||
        changedInputs.indexOf('svgSrc') != -1) {
      if (svgIcon != null) {
        final List l = _splitIconName(svgIcon);
        final namespace = l.first;
        final iconName = l.last;
        try {
          _mdIconRegistry.getNamedSvgIcon(iconName, namespace).listen((svg) {
            _setSvgElement(svg);
          });
        } on MdIconNameNotFoundError catch (error) {
          print('Error retrieving icon: $error');
        }
      } else if (svgSrc != null) {
        _mdIconRegistry.getSvgIconFromUrl(svgSrc).listen((svg) {
          _setSvgElement(svg);
        }).onError((error) {
          print('Error retrieving icon: $error');
        });
      }
    }
    if (_usingFontIcon) {
      _updateFontIconClasses();
    }
    _updateAriaLabel();
  }

  /** TODO: internal */
  ngOnInit() {
    // Update font classes because ngOnChanges won't be called if none of the inputs are present,
    // e.g. <md-icon>arrow</md-icon>. In this case we need to add a CSS class for the default font.
    if (_usingFontIcon) {
      _updateFontIconClasses();
    }
  }

  /** TODO: internal */
  ngAfterViewChecked() {
    // Update aria label here because it may depend on the projected text content.
    // (e.g. <md-icon>home</md-icon> should use 'home').
    _updateAriaLabel();
  }

  _updateAriaLabel() {
    final ariaLabel = _getAriaLabel();
    if (ariaLabel != null && ariaLabel.isNotEmpty) {
      _renderer.setElementAttribute(
          _elementRef.nativeElement, 'aria-label', ariaLabel);
    }
  }

  String _getAriaLabel() {
    // If the parent provided an aria-label attribute value, use it as-is. Otherwise look for a
    // reasonable value from the alt attribute, font icon name, SVG icon name, or (for ligatures)
    // the text content of the directive.
    // FIXME: Overused ternary operators.
    final String label = !isBlank(hostAriaLabel)
        ? hostAriaLabel
        : !isBlank(alt)
            ? alt
            : !isBlank(fontIcon) ? fontIcon : _splitIconName(svgIcon).last;
    if (label != null) {
      return label;
    }
    // The "content" of an SVG icon is not a useful label.
    if (_usingFontIcon) {
      final String text = _elementRef.nativeElement.text;
      if (text != null) {
        return text;
      }
    }
    // TODO: Warn here in dev mode.
    return null;
  }

  bool get _usingFontIcon => !(svgIcon != null || svgSrc != null);

  void _setSvgElement(SvgElement svg) {
    final Element layoutElement = _elementRef.nativeElement;
    // Remove existing child nodes and add the new SVG element.
    // We would use renderer.detachView(Array.from(layoutElement.childNodes)) here,
    // but it fails in IE11: https://github.com/angular/angular/issues/6327
    layoutElement.innerHtml = '';
    _renderer.projectNodes(layoutElement, [svg]);
  }

  _updateFontIconClasses() {
    if (!_usingFontIcon) return;

    final elem = _elementRef.nativeElement;
    final String fontSetClass = fontSet != null
        ? _mdIconRegistry.classNameForFontAlias(fontSet)
        : _mdIconRegistry.defaultFontSetClass;
    if (fontSetClass != _previousFontSetClass) {
      if (_previousFontSetClass != null) {
        _renderer.setElementClass(elem, _previousFontSetClass, false);
      }
      if (fontSetClass.isNotEmpty) {
        _renderer.setElementClass(elem, fontSetClass, true);
      }
      _previousFontSetClass = fontSetClass;
    }

    if (fontIcon != _previousFontIconClass) {
      if (_previousFontIconClass != null) {
        _renderer.setElementClass(elem, _previousFontIconClass, false);
      }
      if (fontIcon != null) {
        _renderer.setElementClass(elem, fontIcon, true);
      }
      _previousFontIconClass = fontIcon;
    }
  }
}

const MD_ICON_DIRECTIVES = const [MdIcon];
