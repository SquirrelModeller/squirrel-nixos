# Daedalus

This is my workstation - my main machine, my daily driver, my all-purpose Linux beast. It builds shit, runs shit, compiles shit, renders shit, and generally never complains.

For years, I had this fantasy:\
I wanted **multiple personalities** on the same machine.

One setup (A) with GPU passthrough for gaming and Windows-related agony.
Another setup (B) without it - stable, clean, normal Linux life.

And I wanted to flip between them like shifting gears.

Except… for the longest time I thought I was stuck doing it the dumb caveman way: wrapping configs in if-statements, toggling variables, rebuilding my entire system each time I wanted to switch modes. A ritual of pain and wasted time.

Then one day, completely by accident, I discovered something that felt genuinely magical:

**NixOS specializations.**

## Specializations, my beloved
I don’t understand why NixOS doesn’t scream about this feature from the rooftops. It’s stupidly powerful. It completely fixes the “I want X and Y on the same machine” problem.

Specializations let you define *multiple fully-scoped system configurations* and switch between them - not only at boot but **live at runtime**. As in: flip a tag, and your machine shape-shifts.

That’s not configuration management.\
That’s sorcery.

Here’s the ridiculous part:
```nix
specialisation.gpu-passthrough.configuration = {
    system.nixos.tags = [ "gpu-passthrough" ];
}
```
That’s it. That’s the whole damn thing.

You wrap your GPU passthrough config in that block, give it a tag, and boom - you now have a dedicated virtualization setup living alongside your normal desktop. Everything inside is scoped. Everything outside stays universal. No fighting, no hacks, no rebuilds for context switching.

For years I brute-forced this like an idiot.\
I genuinely could have cried.

## Windows HELL
Of course, once you've wrestled VFIO into submission and isolated the GPU, you’d expect Windows to just… work. But no. Windows dosen't *work*. It *never* works.

Instead, your GPU outputs what I can only describe as the graphical equivalent of a dying CRT having an LSD episode. Corrupted frames, flashing garbage, random artifacts, pure madness, until you sprinkle this obscure piece of XML voodoo into your VM definition:
```xml
<vendor_id state="on" value="randomid"/>
```
You lie to Windows, pretending your GPU isn’t what it is. And suddenly, as if bribed, Windows behaves.

And then - that first moment - when the login screen actually appears, clean and sharp?\
It’s not pretty, it’s fucking Windows, but it’s beautiful.\
You shed a single tear.

## AMD fuckery
Now, if you thought Windows was the problem, oh mate, welcome to **AMD’s personally hand-crafted GPU passthrough hell**.

If your GPU supports FLR (Function Level Reset), congratulations - you are one of the chosen few. The rest of us? We get this:

Your VM shuts down.\
You stop the GPU.\
Everything is normal.

Then you start the VM again…
…and your GPU is just dead.\
Black screen. No output. No signal. Etched silence.

Because AMD, in their infinite wisdom, decided the entire RX 7000 series should not support FLR. No reset. No reinitialization. No “oh, you want to actually use your GPU again?”\
And they have **no plans** to add FLR ever.

Thanks AMD.\
Truly.\
Masterclass in customer service.

Without FLR, the GPU finishes its first warm-up and then refuses to reset its internal state. It just sits there like:
> “You told me to stop working earlier. Now you want me to start again? Eat shit.”

So how do we revive this stubborn brick without rebooting the entire host?

With an absolute ritualistic nonsense sequence:
```
echo 1 | sudo tee /sys/bus/pci/devices/0000:03:00.0/remove
echo 1 | sudo tee /sys/bus/pci/devices/0000:03:00.1/remove
sudo rtcwake -m mem -s 2
echo 1 | sudo tee /sys/bus/pci/rescan
```
And somehow it brings the damn thing back to life.

## Down the Rabbut Hole of Display Bullshit
Of course, while doing all this, I had exactly one physical monitor.\
So every time I launched or quit the VM, I crawled under the desk - on my knees like a discount Cirque du Soleil performer - swapping the HDMI/DP cable between my iGPU and dGPU.

After doing this enough times to question my life choices, I finally had a revelation:
> This is fucking stupid. There must be a better way.

Enter **Looking Glass**, the patron saint of "I regret buying only one monitor". If only it wasn't so needlessly cryptic. But once you sacrifice your firstborn and recite the forbidden chants, the damn thing works - and when it works, it's glorious.

Looking Glass grabs the raw rendered frames from the passthrough GPU, drops them into `/dev/shm/looking-glass`, and the host client reads them directly. No encoding, no compression

Result?

**It feels like the game is running on Linux natively.**

To make this arcane magic function, your VM needs SPICE channels:
```xml
<channel type="spicevmc">
  <target type="virtio" name="com.redhat.spice.0"/>
  <address type="virtio-serial" controller="0" bus="0" port="1"/>
</channel>
```
And Looking Glass also needs to fiddle with your mouse and keyboard, so you’ll need a SPICE server too. Yes, I know. It sounds like a patchwork of duct tape and eldritch incantations.\
But trust me: once the pieces click, it Just Works™ - unlike half the shit in this setup.

## A virtual ~~girlfriend~~ monitor
Once Looking Glass was working, technically I could stop.\
Obviously I didn’t.

Another cable? Fuck that.\
A dummy plug? Fuck that too.

Then *milkman7755*, an NPC with a side quest, points me to this absolute cheat code:

**VDD: Virtual Display Driver**\
https://github.com/VirtualDrivers/Virtual-Display-Driver

VDD lets you conjure a **virtual monitor** out of thing air. No physicial outputs. No real ports. No adapters. Just pure, synthetic, digital wizardry.

You install the driver inside your VM, and suddenly Windows thinks it has a brand-new monitor plugged in - except the “monitor” is just a virtual output that Looking Glass can latch onto. You can set any resolution, any refresh rate, any absurd ultrawide monstrosity you want. Want a 4K 120Hz fake panel? Sure. Go nuts.

The VM spits out video into that virtual display. Looking Glass grabs it. Linux shows it. And you? You never have to touch a cable again. Not once. Not ever.

Note: Your kneecaps will thank you.


## The Joys of “Why the Fuck Is There No Sound?”
You know that moment when everything is finally working - GPU passed through, Windows tamed with lies, Looking Glass *somehow* working - and you think:
> "Alright... now let's hear this masterpiece

And then: -\
**Silence.**\
The emotional kind.

Because of course you forgot audio, dumbass.


### USB Audio: The Toddler With the Death Grip

Your first instinct:\
“I’ll just pass through my USB headset.”

Huge mistake.

USB passthrough is a jealous toddler.\
Once it grabs your device, it’s gone.\
Host audio? Dead.\
Hotplugging? Dead.

Your headset now lives in Windows permanently.\
You may visit it on weekends.

USB passthrough is a jealous little gremlin. Give it an inch and it will take your entire sound stack, your patience, and possibly your will to live.

### SPICE Audio: The Surprising “Oh Shit This Actually Works” Option

Instead of sacrificing hardware to Windows, you let QEMU emulate a sound card that Windows already understands: ICH9.
```xml
<sound model="ich9">
      <address type="pci" domain="0x0000" bus="0x00" slot="0x1b" function="0x0"/>
    </sound>
<audio id="1" type="spice"/>
```

Windows happily loads the driver.\
QEMU pipes everything through SPICE.\
Linux plays it without crackles or drama.

## Final form
And that's it.
This is the final form of passthrough decadence:
* A GPU inside a VM
* Rendering to a monitor that does not exist
* Displayed on a Linux host that pretends nothing weird is happening
* With audio magically rerouted
* And the whole system mode-switching via NixOS tags like gear shifts

This is the final form of passthrough decadence: A GPU in a VM outputting to a monitor that doesn’t exist, displayed on a host that pretends nothing weird is happening.

It’s stupid.\
It’s brilliant.\
It’s everything I wanted.

This is what Daedalus was always supposed to be - a Linux workstation that can shapeshift into a Windows gaming rig on command, without a single cable sacrificed to the gods.