-keep class com.namit.** { *; }
-keep class java.beans.ConstructorProperties { *; }
-keep class java.beans.Transient { *; }
-keep class org.slf4j.impl.StaticLoggerBinder { *; }
-keep class org.slf4j.impl.StaticMDCBinder { *; }

-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.impl.StaticMDCBinder