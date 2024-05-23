local ____lualib = require("lualib_bundle")
local __TS__Promise = ____lualib.__TS__Promise
local __TS__New = ____lualib.__TS__New
local ____exports = {}
function ____exports.Sleep(self, duration)
    return __TS__New(
        __TS__Promise,
        function(____, resolve)
            Timers:CreateTimer(
                duration,
                function() return resolve(nil, "") end
            )
        end
    )
end
return ____exports
