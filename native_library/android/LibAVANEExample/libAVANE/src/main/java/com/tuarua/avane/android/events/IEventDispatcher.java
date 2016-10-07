package com.tuarua.avane.android.events;

/**
 * Created by User on 02/10/2016.
 */

public interface IEventDispatcher {
    public void addEventListener(String type, IEventHandler cbInterface);
    public void removeEventListener(String type);
    public void dispatchEvent(Event event);
    public Boolean hasEventListener(String type);
    public void removeAllListeners();
}
