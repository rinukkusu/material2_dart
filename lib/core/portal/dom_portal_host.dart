import 'dart:html';
import "dart:async";
import "package:angular2/core.dart";
import "portal.dart";
import "portal_errors.dart";

/**
 * A PortalHost for attaching portals to an arbitrary DOM element outside of the Angular
 * application context.
 *
 * This is the only part of the portal core that directly touches the DOM.
 */
class DomPortalHost extends BasePortalHost {
  Element _hostDomElement;
  ComponentResolver _componentResolver;

  DomPortalHost(this._hostDomElement, this._componentResolver);

  /// Attach the given ComponentPortal to DOM element using the ComponentResolver.
  @override
  Future<ComponentRef> attachComponentPortal(ComponentPortal portal) async {
    if (portal.viewContainerRef == null) {
      throw new MdComponentPortalAttachedToDomWithoutOriginError();
    }
    var componentFactory =
        await _componentResolver.resolveComponent(portal.component);
    var ref = portal.viewContainerRef.createComponent(componentFactory,
        portal.viewContainerRef.length, portal.viewContainerRef.parentInjector);
    var hostView = (ref.hostView as EmbeddedViewRef);
    _hostDomElement.append(hostView.rootNodes[0] as Node);
    setDisposeFn(() => ref.destroy());
    return ref;
  }

  @override
  Future<Map<String, dynamic>> attachTemplatePortal(TemplatePortal portal) {
    var viewContainer = portal.viewContainerRef;
    var viewRef = viewContainer.createEmbeddedView(portal.templateRef);
    viewRef.rootNodes.forEach((Element rootNode) => _hostDomElement.append(rootNode));
    setDisposeFn((() {
      var index = viewContainer.indexOf(viewRef);
      if (index != -1) viewContainer.remove(index);
    }));
    // TODO(jelbourn): Return locals from view.
    return new Future.value(new Map<String, dynamic>());
  }

  @override
  void dispose() {
    super.dispose();
    if (_hostDomElement.parentNode != null) _hostDomElement.remove();
  }
}
