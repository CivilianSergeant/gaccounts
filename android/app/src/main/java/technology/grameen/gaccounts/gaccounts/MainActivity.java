package technology.grameen.gaccounts.gaccounts;

import android.Manifest;
import android.content.pm.PackageManager;
import io.flutter.plugin.common.*;
import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import android.media.MediaScannerConnection;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "scanner";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        MainActivity thisActivity = this;

//        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler(){
            public void onMethodCall(MethodCall call,MethodChannel.Result result){
                switch (call.method) {
                    case "scanFile":
                        MediaScannerConnection.scanFile(thisActivity,new String[]{call.argument("path")},null,null);
                        break;
                }
            }
        });
    }



}
