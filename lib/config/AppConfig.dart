enum Env {SandBox, Prod, Dev}

class AppConfig{
  static Env env = Env.SandBox;

  static Env getEnv(){
      return env;
  }

  static void log(dynamic v,{String line, String className}){
    if(env == Env.Dev || env==Env.SandBox){
      print("[Class:${className!=null? className:''}] [Line: ${line!=null? line : ''}]: " + v.toString());
    }
  }
}