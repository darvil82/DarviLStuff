// This are the options that can be used when setting a cookie
export interface CookieOptions {
	path?: string;
	domain?: string;
	maxAge?: number;
	expires?: Date;
	secure?: boolean;
	samesite?: string;
}

// This is the value that a cookie can have
export type CookieValue = string | number | boolean | Object;


/**
 * Convert a camel cased string to kebab.
 *
 * For example:
 * 	camelCaseString -> camel-case-string
 * @param string
 * @returns The converted string
 */
function camelToKebab(string: string): string {
	return string.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
}

/**
 * Encode a CookieValue into a string
 * @param value
 * @returns
 */
function encodeValue(value: CookieValue): string {
	return encodeURIComponent(
		typeof value === "object" ? JSON.stringify(value) : value
	);
}

/**
 * Decode a string to a CookieValue
 * @param value
 * @returns
 */
function decodeValue(value: string): CookieValue {
	value = decodeURIComponent(value);
	try {
		return JSON.parse(value);
	} catch (error) {
		if (/^[+-]?([0-9]*[.])?[0-9]+$/g.test(value)) return parseFloat(value);
		else if (value === "true" || value === "undefined") return true;
		else if (value === "false") return false;
		else return value;
	}
}


export class Cookies {
	/**
	 * Set a cookie to the document.
	 * @param key The name of the key of the cookie
	 * @param value The value of the cookie
	 * @param options Options for the cookie
	 */
	private static _setCookie(
		key: string,
		value: CookieValue,
		options?: CookieOptions
	) {
		let cookies = [`${key.trim().replace(/=/g, "")}=${encodeValue(value)}`];

		if (options)
			Object.entries(options).forEach(([key, value]) => {
				const pushValue = (value: string | true) => {
					cookies.push(
						camelToKebab(key) + (value !== true ? `=${value}` : "")
					);
				};

				switch (key) {
					case "expires":
						pushValue(value.toUTCString());
						break;
					default:
						pushValue(value);
						break;
				}
			});

		document.cookie = `${cookies.join("; ")};`;
	}

	/**
	 * Set the cookies with the values specified to the document.
	 *
	 * For example:
	 * 	`Cookies.set({ user: { name: "Aster", age: 21 } })`
	 * @param object Object containing multiple keys and values (or one) to set
	 * @param options Options for the cookies that will be set
	 */
	public static set(
		object: { [key: string]: CookieValue },
		options?: CookieOptions
	) {
		Object.entries(object).forEach(([key, value]) => {
			Cookies._setCookie(key, value, options);
		});
	}

	/**
	 * Get the value of the cookie specified. If no name is specified, an object
	 * with all cookies will be returned.
	 * @param name Optional key name to get
	 * @returns An object with all cookies
	 */
	public static get(name?: string): Object {
		const endObj: Object = {};

		document.cookie.split(";").forEach((cookie) => {
			const [key, value] = cookie.trim().split("=");
			if (!key) return;
			endObj[key] = decodeValue(value);
		});

		if (name) {
			if (endObj[name]) return endObj[name];
			else {
				return null;
			}
		}

		return endObj;
	}

	/**
	 * Remove a cookie from the document.
	 * @param names Name/s of the cookies to remove
	 */
	public static remove(...names: string[]) {
		names.forEach((name) => {
			if (!Cookies.get(name)) return;
			Cookies._setCookie(name, "", { maxAge: 0 });
		});
	}

	/**
	 * Remove all cookies from the document.
	 */
	public static removeAll() {
		Cookies.remove(...Object.keys(Cookies.get()));
	}
}
