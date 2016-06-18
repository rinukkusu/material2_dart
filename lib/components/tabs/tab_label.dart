import "package:angular2/core.dart";
import "package:material2_dart/core/portal/portal_directives.dart";

/** Used to flag tab labels for use with the portal directive */
@Directive(selector: "[md-tab-label]")
class MdTabLabel extends TemplatePortalDirective {
  MdTabLabel(TemplateRef templateRef, ViewContainerRef viewContainerRef)
      : super(templateRef, viewContainerRef);
}
