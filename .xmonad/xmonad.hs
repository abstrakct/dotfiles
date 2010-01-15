-------------------------------------------------------------------------------
-- xmonad.hs for xmonad-darcs
-- Author: Øyvind 'Mr.Elendig' Heggstad <mrelendig AT har-ikkje DOT net>
-------------------------------------------------------------------------------
-- Imports --
-- stuff
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
 
-- utils
import XMonad.StackSet as W       (W.shift) 
-- import Xmonad.Util.Run            (spawnPipe, safeSpawn, unsafeSpawn, runInTerm)

-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.ManageHook          (composeAll, doFloat, doF, className, title, (<+>), (=?), (-->))

-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Named
import XMonad.Layout.Tabbed
 
-------------------------------------------------------------------------------
-- Main --
main :: IO ()
main = xmonad =<< statusBar cmd pp kb conf
  where
    uhook = withUrgencyHookC NoUrgencyHook urgentConfig
    cmd = "xmobar"
    pp = customPP
    kb = toggleStrutsKey
    conf = uhook myConfig
 
-------------------------------------------------------------------------------
-- Configs --
myConfig = defaultConfig { workspaces = workspaces'
                         , modMask = modMask'
                         , borderWidth = borderWidth'
                         , normalBorderColor = normalBorderColor'
                         , focusedBorderColor = focusedBorderColor'
                         , terminal = terminal'
                         , keys = keys'
                         , layoutHook = layoutHook'
                         , manageHook = myManageHook
                         }
 
-------------------------------------------------------------------------------
-- Helpers --
-- avoidMaster: Avoid the master window, but otherwise manage new windows normally
avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
    W.Stack t [] (r:rs) -> W.Stack t [r] rs
    otherwise -> c
 
-------------------------------------------------------------------------------
-- Window Management --
--manageHook' = composeAll [ doF avoidMaster -- replace with X.H.InsertPosition ?
myManageHook :: ManageHook
myManageHook = composeAll . concat $
    [ [ className =? c    --> doFloat | c <- myFloats]
    , [ title =? t        --> doFloat | t <- myOtherFloats]
    , [ className =? "Firefox"  --> doF (W.shift "II-web") ]
    , [ className =? "Shiretoko" --> doF (W.shift "II-web") ]
    , [ className =? "Uzbl browser"     --> doF (W.shift "II-web") ]
    ]
    where
        myFloats = ["feh", "gimp", "vlc", "MPlayer"]
        myOtherFloats = ["Firefox Preferences", "Dwarf Fortress", "Uzbl browser"]

--						 , isFullscreen --> doFullFloat
--                         , className =? "MPlayer" --> doFloat
--                         , className =? "Shiretoko" --> doFloat
--                         , className =? "Gimp" --> doFloat
--                         , className =? "Vlc" --> doFloat
--						 , className =? "Dwarf Fortress" --> doFloat
--						 , className =? "Terminal" --> doFloat
--						 ]
 
-------------------------------------------------------------------------------
-- Looks --
-- bar
customPP = defaultPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">"
                     , ppHidden = xmobarColor "#C98F0A" ""
                     , ppHiddenNoWindows = xmobarColor "#C9A34E" ""
                     , ppUrgent = xmobarColor "#FFFFAF" "" . wrap "[" "]"
                     , ppLayout = xmobarColor "#C9A34E" ""
                     , ppTitle = xmobarColor "#C9A34E" "" . shorten 80
                     , ppSep = xmobarColor "#429942" "" " | "
                     }
 
-- urgent notification
urgentConfig = UrgencyConfig { suppressWhen = Focused, remindWhen = Dont }
 
-- borders
borderWidth' = 1
normalBorderColor' = "#333333"
focusedBorderColor' = "#AFAF87"
 
-- tabs
tabTheme1 = defaultTheme { decoHeight = 16
                         , activeColor = "#a6c292"
                         , activeBorderColor = "#a6c292"
                         , activeTextColor = "#000000"
                         , inactiveBorderColor = "#000000"
                         }
 
-- workspaces
workspaces' = ["I-main", "II-web", "III", "IV", "V", "VI", "VII", "VIII", "IX"]
 
-- layouts
layoutHook' = tile ||| mtile ||| full
  where
    rt = named "rt" $ ResizableTall 1 (2/100) (1/2) []
    tile = named "[]=" $ smartBorders rt
    mtile = named "M[]=" $ smartBorders $ Mirror rt
    -- tab = named "T" $ noBorders $ tabbed shrinkText tabTheme1
    full = named "[]" $ noBorders Full
 
-------------------------------------------------------------------------------
-- Terminal --
terminal' = "urxvtc"
 
-------------------------------------------------------------------------------
-- Keys/Button bindings --
-- modmask
modMask' = mod4Mask
 
-- keys
toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)
 
keys' :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launching and killing programs
    [ ((modMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask, xK_p ), spawn "dodmenu")
--    , ((modMask .|. shiftMask, xK_p ), spawn "gmrun")
--    , ((modMask .|. shiftMask, xK_m ), spawn "claws-mail")
    , ((modMask, xK_u ), spawn "uzbl-browser")
    , ((modMask, xK_f ), spawn "firefox")
    , ((modMask .|. shiftMask, xK_c ), kill)
 
    -- layouts
    , ((modMask, xK_space ), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- floating layer stuff
    , ((modMask, xK_t ), withFocused $ windows . W.sink)
 
    -- refresh
    , ((modMask, xK_n ), refresh)
 
    -- focus
    , ((modMask, xK_Tab ), windows W.focusDown)
    , ((modMask, xK_j ), windows W.focusDown)
    , ((modMask, xK_k ), windows W.focusUp)
    , ((modMask, xK_m ), windows W.focusMaster)
 
    -- swapping
    , ((modMask .|. shiftMask, xK_Return), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j ), windows W.swapDown )
    , ((modMask .|. shiftMask, xK_k ), windows W.swapUp )
 
    -- increase or decrease number of windows in the master area
    , ((modMask , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask , xK_period), sendMessage (IncMasterN (-1)))
 
    -- resizing
    , ((modMask, xK_h ), sendMessage Shrink)
    , ((modMask, xK_l ), sendMessage Expand)
    , ((modMask .|. shiftMask, xK_h ), sendMessage MirrorShrink)
    , ((modMask .|. shiftMask, xK_l ), sendMessage MirrorExpand)
 
    -- multimedia keys
    , ((0, 0x1008ff15), spawn "mpc stop")
    , ((0, 0x1008ff16), spawn "mpc prev")
    , ((0, 0x1008ff17), spawn "mpc next")
    , ((0, 0x1008ff14), spawn "mpc toggle")
    , ((0, 0x1008ff11), spawn "ossmix jack.int-speaker.int-speaker -- -2")
    , ((0, 0x1008ff13), spawn "ossmix jack.int-speaker.int-speaker +2")
    , ((0, 0x1008ff12), spawn "ossmix jack.int-speaker.int-speaker 0")
    , ((0, 0x1008ff81), spawn "thunar /mnt/win/Users/Rolf/Videos")
    , ((0, 0x1008ff2e), spawn "xmonad --recompile; xmonad --restart")
    , ((0, 0x1008ff2f), io (exitWith ExitSuccess))

    -- quit, or restart
    , ((modMask .|. shiftMask, xK_q ), io (exitWith ExitSuccess))
    , ((modMask , xK_q ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-[w,e] %! switch to twinview screen 1/2
    -- mod-shift-[w,e] %! move window to screen 1/2
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
 
-------------------------------------------------------------------------------
 
