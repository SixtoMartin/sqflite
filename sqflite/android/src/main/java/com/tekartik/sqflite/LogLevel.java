package com.tekartik.sqflite;

import io.flutter.plugin.common.MethodCall;

import static com.tekartik.sqflite.Constant.PARAM_LOG_LEVEL;

public class LogLevel {

    static final int none = 0;
    static final int sql = 1;
    static final int verbose = 2;

    static int getLogLevel(MethodCall methodCall) {
        Integer level =methodCall.argument(PARAM_LOG_LEVEL);
        if (level == null) {
            return none;
        }
        return level;
    }

    static boolean hasSqlLovel(int level) {
        return level >= sql;
    }

    static boolean hasVerboseLevel(int level) {
        return level >= verbose;
    }
}
