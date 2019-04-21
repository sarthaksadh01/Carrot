package com.example.simosa;

import android.os.Parcelable;

public interface MyInterface extends Parcelable {
    void join(String s);
    void error(String s);
    void leave(String s);
}
