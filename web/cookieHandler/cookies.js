/**
 * Convert a camel cased string to kebab.
 *
 * For example:
 * 	camelCaseString -> camel-case-string
 * @param string
 * @returns The converted string
 */
function camelToKebab(string) {
    return string.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
}
/**
 * Encode a CookieValue into a string
 * @param value
 * @returns
 */
function encodeValue(value) {
    let endValue;
    if (typeof value == "object")
        endValue = JSON.stringify(value);
    else
        endValue = `${value}`;
    return encodeURIComponent(endValue);
}
/**
 * Decode a string to a CookieValue
 * @param value
 * @returns
 */
function decodeValue(value) {
    value = decodeURIComponent(value);
    try {
        return JSON.parse(value);
    }
    catch (error) {
        if (/^[+-]?([0-9]*[.])?[0-9]+$/g.test(value))
            return parseInt(value);
        else if (value === "true" || value === "undefined")
            return true;
        else if (value === "false")
            return false;
        else
            return value;
    }
}
class Cookies {
    /**
     * Set a cookie to the document.
     * @param key The name of the key of the cookie
     * @param value The value of the cookie
     * @param options Options for the cookie
     */
    _setCookie(key, value, options) {
        let endString = [`${key}=${encodeValue(value)}`];
        if (options)
            Object.entries(options).forEach(([key, value]) => {
                const push_value = (value) => {
                    endString.push(camelToKebab(key) +
                        (value !== true
                            ? `=${value}`
                            : ""));
                };
                switch (key) {
                    case "expires":
                        push_value(value.toUTCString());
                        break;
                    default:
                        push_value(value);
                        break;
                }
            });
        document.cookie = `${endString.join("; ")};`;
    }
    /**
     * Set the cookies with the values specified to the document.
     *
     * For example:
     * 	`Cookies.set({ user: { name: "Aster", age: 21 } })`
     * @param object Object containing multiple keys and values (or one) to set
     * @param options Options for the cookies that will be set
     */
    set(object, options) {
        Object.entries(object).forEach(([key, value]) => {
            this._setCookie(key, value, options);
        });
    }
    /**
     * Get the value of the cookie specified. If no name is specified, an object
     * with all cookies will be returned.
     * @param name Optional key name to get
     * @returns An object with all cookies
     */
    get(name) {
        const endObj = {};
        document.cookie.split(";").forEach(cookie => {
            const [key, value] = cookie.trim().split("=");
            if (!key)
                return;
            endObj[key] = decodeValue(value);
        });
        if (name)
            return endObj[name];
        return endObj;
    }
    /**
     * Remove a cookie from the document.
     * @param names Name/s of the cookies to remove
     */
    remove(...names) {
        names.forEach(name => {
            this._setCookie(name, "", { maxAge: 0 });
        });
    }
}
var cookies = new Cookies();
//# sourceMappingURL=cookies.js.map