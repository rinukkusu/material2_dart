import "package:angular2/core.dart";
import "../../core/core.dart";

/// Used to flag tab contents for use with the portal directive.
@Directive(selector: "[md-tab-content]")
class MdTabContent extends TemplatePortalDirective {
  MdTabContent(TemplateRef templateRef, ViewContainerRef viewContainerRef)
      : super(templateRef, viewContainerRef);
}
