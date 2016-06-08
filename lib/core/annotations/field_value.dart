/**
 * Annotation Factory that allows HTML style boolean attributes. For example,
 * a field declared like this:

 * @Directive({ selector: 'component' }) class MyComponent {
 *   @Input() @BooleanFieldValueFactory() myField: boolean;
 * }
 *
 * You could set it up this way:
 *   <component myField>
 * or:
 *   <component myField="">
 */
booleanFieldValueFactory() {
  Function booleanFieldValueMetadata = (dynamic target, String key) {
    var defaultValue = target[key];
    var localKey = '__md_private_symbol_$key';
    target[localKey] = defaultValue;

    // Prob need reflectable.
//    Object.defineProperty(target, key, {
//      get() { return (<any>this)[localKey]; },
//      set(value: boolean) {
//        (<any>this)[localKey] = value != null && `${value}` !== 'false';
//      }
//    });
  };
  return booleanFieldValueMetadata;
}

//export { booleanFieldValueFactory as BooleanFieldValue };
