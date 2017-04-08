import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Util.EZConfig
import XMonad.Hooks.SetWMName
import Graphics.X11.ExtraTypes.XF86
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask,               xK_p     ), spawn "dmenu_run")
    , ((modMask .|. shiftMask, xK_p     ), spawn "gmrun")
    , ((modMask .|. shiftMask, xK_c     ), kill)
    , ((modMask,               xK_space ), sendMessage NextLayout)
    -- Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)
    , ((modMask,               xK_Tab   ), windows W.focusDown)
    , ((modMask,               xK_j     ), windows W.focusDown)
    , ((modMask,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modMask,               xK_h     ), sendMessage Shrink)
    , ((modMask,               xK_l     ), sendMessage Expand)
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))
--    , ((modMask              , xK_b     ), sendMessage ToggleStruts)
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modMask, xK_q),   spawn "xmonad --recompile; xmonad --restart")
--    , ((noModMask, xF86XK_AudioMute),        spawn "amixer set Master toggle")
    , ((noModMask, xF86XK_AudioRaiseVolume), spawn "amixer set Master 2+ unmute")
    , ((noModMask, xF86XK_AudioLowerVolume), spawn "amixer set Master 2- unmute")
    ]
    ++
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w
                                        >> windows W.shiftMaster))
    , ((modMask, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w
                                        >> windows W.shiftMaster))
    ]

myLayout = tiled ||| Mirror tiled ||| Full
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "weka-gui-GUIChooser" --> doFloat
    , className =? "XChat"          --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "Plugin-container" --> doFloat
    , className =? "Nvidia-settings" --> doFloat
    , className =? "Skype"          --> doFloat
    , className =? "XTerm"          --> doFloat
    , className =? "stalonetray"     --> doIgnore
    , className =? "ScreenRuler"     --> doIgnore
    , className =? "netease-cloud-music" --> doFloat
    , title =? "Guake!" --> doFloat
    , title =? "Guake Preferences" --> doFloat
    , title =? "Variety Preferences" --> doFloat
    , className =? "Thunderbird" <&&> resource =? "Dialog" --> doFloat

    -- eclipse
    , className =? "Java" <&&> resource =? "java" --> doFloat
    , className =? "Firefox" <&&> resource =? "Dialog" --> doFloat
    ]

main = xmonad =<< statusBar "xmobar" xmobarPP toggleStrutsKey defaults

toggleStrutsKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)

defaults = defaultConfig {
      terminal           = "xterm -geometry 180x60+300+200",
      focusFollowsMouse  = True,
      clickJustFocuses   = False,
      borderWidth        = 1,
      modMask            = mod4Mask,
      workspaces         = ["1","2","3","4","5","6","7","8","9"],
      normalBorderColor  = "#323232",
      focusedBorderColor = "#555555",

      keys               = myKeys,
      mouseBindings      = myMouseBindings,

      layoutHook         = myLayout,
      manageHook         = myManageHook,
      handleEventHook    = mempty,
      logHook            = return (),
      startupHook        = setWMName "LG3D"
  }

