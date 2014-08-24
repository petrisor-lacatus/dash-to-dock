// -*- mode: js; js-indent-level: 4; indent-tabs-mode: nil -*-

const Me = imports.misc.extensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;
const Intellihide = Me.imports.intellihide;
const DockedDash = Me.imports.dockedDash;

let settings;
let intellihide;
let dock;

function init() {

}

function show(){

    dock.disableAutoHide();
}

function hide(){

    dock.enableAutoHide();
}

function enable() {

    settings = Convenience.getSettings('org.gnome.shell.extensions.dash-to-dock');
    dock = new DockedDash.dockedDash(settings);
    intellihide = new Intellihide.intellihide(show, hide, dock, settings);

    bindSettingsChanges();

}

function disable() {
    intellihide.destroy();
    dock.destroy();
    settings.run_dispose();

    dock=null;
    intellihide=null;
    settings = null;
}


function bindSettingsChanges() {
    // This settings change require a full reload.
    settings.connect('changed::dock-placement', function(){
        disable();
        enable();
    });
}
