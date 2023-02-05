import { Beer, FetchResult } from "./pages/app/App";

export default class Mocks {
  static MOCK_QUERY = "Ale";

  static MOCK_BEER_1: Beer = {
    id: 2,
    name: "Trashy Blonde",
    tagline: "You Know You Shouldn't",
    description: "Desc...",
    image_url: "https://images.punkapi.com/v2/2.png",
    abv: 4.1,
    food_pairing: ["Pairing 1...", "Pairing 2..."],
    brewers_tips: "Tips...",
  };

  static MOCK_BEER_2: Beer = {
    id: 8,
    name: "Fake Lager",
    tagline: "Bohemian Pilsner.",
    description: "Desc...",
    image_url: "https://images.punkapi.com/v2/8.png",
    abv: 4.7,
    food_pairing: ["Pairing 1...", "Pairing 2..."],
    brewers_tips: "Tips...",
  };

  static MOCK_BEER_3: Beer = {
    id: 18,
    name: "Russian Doll – India Pale Ale",
    tagline: "Nesting Hop Bomb.",
    description: "Desc...",
    image_url: "https://images.punkapi.com/v2/18.png",
    abv: 6,
    food_pairing: ["Pairing 1...", "Pairing 2..."],
    brewers_tips: "Tips...",
  };

  static MOCK_RESPONSE_ERROR: FetchResult = {
    beers: [],
    cached: true,
    has_next_page: false,
    error: new Error("Test error message..."),
  };

  static MOCK_RESPONSE_NO_NEXT_3: FetchResult = {
    beers: [this.MOCK_BEER_1, this.MOCK_BEER_2, this.MOCK_BEER_3],
    cached: true,
    has_next_page: false,
    error: null,
  };

  static MOCK_RESPONSE_HAS_NEXT_10: FetchResult = {
    beers: [
      this.MOCK_BEER_1,
      this.MOCK_BEER_2,
      this.MOCK_BEER_3,
      this.MOCK_BEER_2,
      this.MOCK_BEER_2,
      this.MOCK_BEER_2,
      this.MOCK_BEER_3,
      this.MOCK_BEER_3,
      this.MOCK_BEER_3,
      this.MOCK_BEER_3,
    ],
    cached: true,
    has_next_page: true,
    error: null,
  };

  /** Mock the assign callback and the URL parameters */
  static mockLocation(parameters: string = ""): void {
    const newUrl =
      window.location.protocol +
      "//" +
      window.location.host +
      window.location.pathname +
      parameters;

    const location = new URL(newUrl);
    (location as any).assign = jest.fn();
    delete (window as any).location;
    (window as any).location = location;
  }
}
