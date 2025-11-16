# Daedalus

This is my workstation.

For the longest time, I wanted to have multiple "versions" of the same machine. One setup (let's call it *A*) with GPU passthrough, and another (*B*) without it - and I've dreamed of just flipping between them like changing gears.

But for years I thought I was stuck doing it the dumb way - guarding different configs with variables, then rebuilding the whole system whenever I needed to switch. A pain in the ass.

And then I discovered something magical: **NixOS specializations**.

## Specializations, my beloved

Why the hell does Nix not shout about this feature more? It’s absurdly powerful. It fixes the whole problem.

Specializations let you have multiple setups on the same machine and swap between them either at boot or - wait for it - **at runtime**. Yeah. You can literally flip your system configuration live. It's fucking magic, it must be.

And the best part of this? It's stupidly simple.
```nix
specialisation.gpu-passthrough.configuration = {
    system.nixos.tags = [ "gpu-passthrough" ];
}
```

That is litteraly it. Done. You just define a scoped configuration for your GPU passthrough setup, give it a tag, and it lives happily alongside your default system. Everything inside that scope applies *only* to that specialization. Everything outside stays part of the baseline.




## Windows HELL
You'd think that once you've wrestled VFIO into submission and gotten your GPU isolated, Windows would just... work. But no. Windows dosen't *work*. It **never** *works*. 

For some ungodly reason, your GPU will start spewing corrupted pixels like a dying CRT on acid - until you sprinkle this obscure piece of XML voodoo into your VM definition:
```xml
<vendor_id state="on" value="randomid"/>
```
You lie to Windows, pretending your GPU isn’t what it is, and suddenly it behaves. And then - that first moment - when the Windows login screen flickers into existence? It's not pretty (because, well, Windows), but goddamn does it feel *beautiful*. You shed a tear.

## AMD fuckery
Now, if you thought Windows was the problem, oh mate - welcome to **AMD's specially made hell**.

You *might* be one of the blessed few whose GPU support **FLR** - Function Level Reset - which lets your GPU gracefully reset itself after a VM shutdown. Lucky prick. The rest of us, we get enernal dfarkness.

No signal. No reboot. No output. Just a silent GPU sitting there. The amount of time I've spent debugging this issue, I've gone half insane, I swear I can hear it say "You told me to stop working, and now you want me to start again? Fuck off.".

You see, without FLR, your GPU can't reset cleanly. It just... stays dead until you reboot the whole machine. Which is great, except the whole point of passthrough is *not* rebooting the goddamn host every time.

And it just so happens that the RX 7000 series does **NOT** support FSR. At all. AMD has *no plans* for adding it to that line of GPUs. Thanks AMD. You really bent us over the barrel and railed us.

So how do we actually fix this, without rebooting the entire PC?

```bash
echo 1 | sudo tee /sys/bus/pci/devices/0000:03:00.0/remove
echo 1 | sudo tee /sys/bus/pci/devices/0000:03:00.1/remove
echo -n mem > /sys/power/state
echo 1 | sudo tee /sys/bus/pci/rescan
```