package states;

import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import options.ControlsSubState;

class DesktopBindsState extends MusicBeatState
{
    override function create()
    {
        super.create();

        openSubState(new ControlsSubState(true));
        subStateClosed.add(onSubStateClosed);
    }

    function onSubStateClosed(subState:FlxSubState) {
        FlxG.save.data.setDesktopBinds = true;
        ClientPrefs.saveSettings();
        
        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
        MusicBeatState.switchState(new TitleState());
    }
}