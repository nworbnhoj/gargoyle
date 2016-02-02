# gargoyle
## Bleeding Edge

The Bleeding Edge includes Gargoyle developments that have not yet been reviewed or merged into Gargoyle. 

[Images](https://github.com/nworbnhoj/gargoyle/tree/bleeding-edge/images/ar71xx) are available based on automated builds. Please do not flash these images to your router unless you have bricked a router or two and are familiar with the [Gargoyle](https://www.gargoyle-router.com/wiki/doku.php?id=failsafe_mode_recovery)/[OpenWrt](http://wiki.openwrt.org/doc/howto/generic.failsafe) recovery process. Not suitable for 4M routers. **Consider yourself duly warned**.

That said, I run this bleeding-edge build on my personal home router and all of the code included in the bleeding-edge has an open Pull Request on the Gargoyle master awaiting review.

Currently the additional functionality included in the bleeding-edge is:
- **Known Groups** The idea is to be able to set policy (Quota, QoS, Restrictions etc) over a Group of Known Devices (owned by an individual for example). To achieve this, the Known Devices need to be identified by their MAC address' and then arranged into Groups. Both Devices and Groups can be named by the Gargoyle Administrator [more...](https://github.com/nworbnhoj/gargoyle/tree/known-devices#gargoyle)
- **Quota Usage Improvements** Color coded % usage and Bytes usage. 
- **Table Sorting** On 9 tables
- **Security Improvements** SSH authorized key management and stronger https encryption 

Please provide your feedback in the [Gargoyle forum](https://www.gargoyle-router.com/phpbb/index.php)
