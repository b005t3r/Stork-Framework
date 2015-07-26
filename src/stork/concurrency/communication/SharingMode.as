/**
 * User: booster
 * Date: 26/07/15
 * Time: 10:49
 */
package stork.concurrency.communication {
import medkit.enum.Enum;

public class SharingMode extends Enum {
    { initEnums(SharingMode); }

    public static const Copy:SharingMode        = new SharingMode();
    public static const Serialize:SharingMode   = new SharingMode();
}
}
