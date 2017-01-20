import 'dart:async';

import 'dart:html';
import 'package:angular2/core.dart';

/**
 * This is the interface for focusable items (used by the ListKeyManager).
 * Each item must know how to focus itself and whether or not it is currently disabled.
 */
abstract class MdFocusable {
  void focus();
  bool disabled;
}


/**
 * This class manages keyboard events for selectable lists. If you pass it a query list
 * of focusable items, it will focus the correct item when arrow events occur.
 */
class ListKeyManager {
  num _focusedItemIndex;
  StreamController<dynamic> _tabOut = new StreamController<dynamic>();
  bool _wrap = false;

  QueryList<MdFocusable> _items;

  ListKeyManager(QueryList<MdFocusable> _items);

  /**
   * Turns on focus wrapping mode, which ensures that the focus will wrap to
   * the other end of list when there are no more items in the given direction.
   */
  ListKeyManager withFocusWrap() {
    _wrap = true;
    return this;
  }

  /** Sets the focus of the list to the item at the index specified. */
  void setFocus(num index) {
    _focusedItemIndex = index;
    _items.toList()[index].focus();
  }

  /** Sets the focus properly depending on the key event passed in. */
  void onKeydown(KeyboardEvent event) {
    switch (event.keyCode) {
      case KeyCode.DOWN:
        focusNextItem();
        break;
      case KeyCode.UP:
        focusPreviousItem();
        break;
      case KeyCode.HOME:
        focusFirstItem();
        break;
      case KeyCode.END:
        focusLastItem();
        break;
      case KeyCode.TAB:
        _tabOut.add(null);
        break;
    }
  }

  /** Focuses the first enabled item in the list. */
  void focusFirstItem() {
    _setFocusByIndex(0, 1);
  }

  /** Focuses the last enabled item in the list. */
  void focusLastItem() {
    _setFocusByIndex(this._items.length - 1, -1);
  }

  /** Focuses the next enabled item in the list. */
  void focusNextItem() {
    _setFocusByDelta(1);
  }

  /** Focuses a previous enabled item in the list. */
  void focusPreviousItem() {
    _setFocusByDelta(-1);
  }

  /** Returns the index of the currently focused item. */
  num get focusedItemIndex {
    return _focusedItemIndex;
  }

  /**
   * Stream that emits any time the TAB key is pressed, so components can react
   * when focus is shifted off of the list.
   */
  Stream<dynamic> get tabOut {
    return this._tabOut.stream;
  }

  /**
   * This method sets focus to the correct item, given a list of items and the delta
   * between the currently focused item and the new item to be focused. It will calculate
   * the proper focus differently depending on whether wrap mode is turned on.
   */
  void _setFocusByDelta(num delta, [List<MdFocusable> items = null]) {
    items ??= _items.toList();
    this._wrap ? _setWrapModeFocus(delta, items)
        : _setDefaultModeFocus(delta, items);
  }

  /**
   * Sets the focus properly given "wrap" mode. In other words, it will continue to move
   * down the list until it finds an item that is not disabled, and it will wrap if it
   * encounters either end of the list.
   */
  void _setWrapModeFocus(num delta, List<MdFocusable> items) {
    // when focus would leave menu, wrap to beginning or end
    _focusedItemIndex =
      (_focusedItemIndex + delta + items.length) % items.length;

    // skip all disabled menu items recursively until an active one is reached
    if (items[_focusedItemIndex].disabled) {
      _setWrapModeFocus(delta, items);
    } else {
      items[_focusedItemIndex].focus();
    }
  }

  /**
   * Sets the focus properly given the default mode. In other words, it will
   * continue to move down the list until it finds an item that is not disabled. If
   * it encounters either end of the list, it will stop and not wrap.
   */
  void _setDefaultModeFocus(num delta, List<MdFocusable> items) {
    _setFocusByIndex(_focusedItemIndex + delta, delta, items);
  }

  /**
   * Sets the focus to the first enabled item starting at the index specified. If the
   * item is disabled, it will move in the fallbackDelta direction until it either
   * finds an enabled item or encounters the end of the list.
   */
  void _setFocusByIndex(num index, num fallbackDelta,
    [List<MdFocusable> items = null]) {
    items ??= _items.toList();

    if (items[index] == null) { return; }
    while (items[index].disabled) {
      index += fallbackDelta;
      if (items[index] == null) { return; }
    }
    this.setFocus(index);
  }

}