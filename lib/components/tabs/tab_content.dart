import "package:angular2/core.dart";
import "package:material2_dart/core/portal/portal_directives.dart";

/** Used to flag tab contents for use with the portal directive */
@Directive(selector: "[md-tab-content]")
class MdTabContent extends TemplatePortalDirective {
  MdTabContent(TemplateRef templateRef, ViewContainerRef viewContainerRef)
      : super(templateRef, viewContainerRef);
}
