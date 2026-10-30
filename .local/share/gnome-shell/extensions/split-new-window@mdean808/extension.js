import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const LAYOUTS = {
    '<Super>backslash': 'side-by-side',
    '<Super>minus': 'stacked',
};
const NEW_WINDOW_TIMEOUT_MS = 5000;

function halves(workArea, layout) {
    const {x, y, width, height} = workArea;
    if (layout === 'side-by-side') {
        const left = Math.floor(width / 2);
        return [
            {x, y, width: left, height},
            {x: x + left, y, width: width - left, height},
        ];
    }
    const top = Math.floor(height / 2);
    return [
        {x, y, width, height: top},
        {x, y: y + top, width, height: height - top},
    ];
}

function place(window, rect) {
    if (window.is_fullscreen())
        window.unmake_fullscreen();
    if (window.is_maximized())
        window.unmaximize();
    window.move_resize_frame(true, rect.x, rect.y, rect.width, rect.height);
}

export default class SplitNewWindowExtension extends Extension {
    enable() {
        this._layouts = new Map();
        for (const [accelerator, layout] of Object.entries(LAYOUTS)) {
            const action = global.display.grab_accelerator(accelerator, Meta.KeyBindingFlags.NONE);
            if (action === Meta.KeyBindingAction.NONE) {
                console.warn(`${this.uuid}: ${accelerator} is taken by another shortcut`);
                continue;
            }
            Main.wm.allowKeybinding(Meta.external_binding_name_for_action(action), Shell.ActionMode.NORMAL);
            this._layouts.set(action, layout);
        }

        this._acceleratorId = global.display.connect('accelerator-activated', (_display, action) => {
            const layout = this._layouts.get(action);
            if (layout)
                this._split(layout);
        });
    }

    disable() {
        global.display.disconnect(this._acceleratorId);
        for (const action of this._layouts.keys()) {
            Main.wm.allowKeybinding(Meta.external_binding_name_for_action(action), Shell.ActionMode.NONE);
            global.display.ungrab_accelerator(action);
        }
        this._layouts = null;
        this._stopWaiting();
    }

    _split(layout) {
        const window = global.display.focus_window;
        if (!window || window.get_window_type() !== Meta.WindowType.NORMAL)
            return;

        const [first, second] = halves(window.get_work_area_current_monitor(), layout);
        place(window, first);

        const app = Shell.WindowTracker.get_default().get_window_app(window);
        if (!app?.can_open_new_window())
            return;

        this._waitForNewWindow(app, second);
        app.open_new_window(-1);
    }

    _waitForNewWindow(app, rect) {
        this._stopWaiting();

        const known = new Set(app.get_windows());
        const windowsChangedId = app.connect('windows-changed', () => {
            const window = app.get_windows().find(w =>
                !known.has(w) && w.get_window_type() === Meta.WindowType.NORMAL);
            if (!window)
                return;

            this._stopWaiting();
            const actor = window.get_compositor_private();
            if (!actor) {
                place(window, rect);
                return;
            }
            const firstFrameId = actor.connect('first-frame', () => {
                actor.disconnect(firstFrameId);
                place(window, rect);
            });
        });
        const timeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, NEW_WINDOW_TIMEOUT_MS, () => {
            this._waiting.timeoutId = 0;
            this._stopWaiting();
            return GLib.SOURCE_REMOVE;
        });

        this._waiting = {app, windowsChangedId, timeoutId};
    }

    _stopWaiting() {
        if (!this._waiting)
            return;

        const {app, windowsChangedId, timeoutId} = this._waiting;
        app.disconnect(windowsChangedId);
        if (timeoutId)
            GLib.source_remove(timeoutId);
        this._waiting = null;
    }
}
