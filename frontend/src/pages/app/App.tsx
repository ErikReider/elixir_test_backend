import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { FadeLoader } from "react-spinners";
import Popup from "reactjs-popup";
import Item from "../../components/item/Item";
import "./App.scss";

export interface Beer {
  id: Number;
  abv: Number;
  brewers_tips: string;
  image_url: string;
  name: string;
  tagline: string;
  description: string;
  food_pairing: string[];
}

export interface FetchResult {
  beers: Beer[];
  cached: boolean;
  has_next_page: boolean;
  error: Error | null;
}

function App() {
  const [query, setQuery] = useState("");
  const [pageNr, setPageNr] = useState(1);
  const [result, setResult] = useState<FetchResult | null>(null);
  const [popupBeer, setPopupBeer] = useState<Beer | null>(null);
  const [searchParams, _setSearchParams] = useSearchParams();

  const fetchEntries = (query: string, pageNr: number): void => {
    fetch(
      `${process.env.REACT_APP_BACKEND_URL}?query=${query}&page_nr=${pageNr}`,
      {
        method: "GET",
        headers: {
          accepts: "application/json",
        },
      }
    )
      .then(async (result): Promise<FetchResult> => {
        const contentType = result.headers.get("content-type") ?? "";
        if (result.status !== 200) {
          throw new Error("Result status not 200!...");
        } else if (!result.ok) {
          throw new Error("Result not OK!...");
        } else if (!contentType.includes("application/json")) {
          throw new Error("Result not in JSON format!...");
        }
        return await result.json();
      })
      .then((json) => setResult(json))
      .catch((reason) =>
        setResult({
          beers: [],
          cached: false,
          has_next_page: false,
          error: reason,
        })
      );
  };

  /** Defaults to 1 if invalid */
  const getPageNr = (): number => {
    const arg_nr = decodeURI(searchParams.get("page_nr") ?? "");
    const converted = Number(arg_nr);
    if (arg_nr && !isNaN(converted) && converted > 0) {
      return converted;
    }
    return 1;
  };

  /** Defaults to an empty string if invalid */
  const getQuery = (): string => {
    return decodeURI(searchParams.get("query") ?? "");
  };

  const navigate = (query: string, pageNr: number = 1): void => {
    let newUrl =
      window.location.protocol +
      "//" +
      window.location.host +
      window.location.pathname;
    if (query) {
      newUrl += `?query=${encodeURI(query)}&page_nr=${encodeURI(
        pageNr.toString()
      )}`;
    }
    window.location.assign(newUrl);
  };

  const handleNavigatePages = (next: boolean): void => {
    navigate(query, Math.max(1, pageNr + (next ? 1 : -1)));
  };

  useEffect(() => {
    const pageNr = getPageNr();
    const query = getQuery();
    if (query) {
      setQuery(query);
      setPageNr(pageNr);
      fetchEntries(query, pageNr);
    } else {
      setResult({
        beers: [],
        cached: false,
        has_next_page: false,
        error: null,
      });
    }
  }, [""]);

  const getPageNavigationButtons = (): JSX.Element => {
    return (
      <div key="page-navigation-buttons" className="page-direction-box">
        <button
          className="button"
          disabled={pageNr <= 1}
          onClick={() => handleNavigatePages(false)}
        >
          &#8249;
        </button>
        <button
          className="button"
          disabled={!result?.has_next_page}
          onClick={() => handleNavigatePages(true)}
        >
          &#8250;
        </button>
      </div>
    );
  };

  const getResultsList = (): JSX.Element => {
    if (!getQuery()) return <span>Search for beers</span>;
    if (!result) return <FadeLoader />;
    if (result.error) {
      return <span role="error-msg">Error: {result.error.message}</span>;
    }
    if (result.beers.length == 0) return <span>No beers found...</span>;
    return (
      <>
        <div className="items">
          {result.beers.map((beer, i) => (
            <Item
              key={`${beer.name}-${beer.id}-${i}`}
              clickCb={(beer) => setPopupBeer(beer)}
              beer={beer}
            />
          ))}
        </div>
        {getPageNavigationButtons()}
      </>
    );
  };

  return (
    <div className="App">
      <form
        className="search-box"
        onSubmit={(event) => {
          navigate(query);
          event.preventDefault();
        }}
      >
        <input type="hidden" value={pageNr} />
        <input
          type="search"
          name="name"
          placeholder="Search for beers"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
        />
        <input type="submit" className="button" value="Search 🍺" />
      </form>

      <section
        className={"result-box" + (result?.beers.length ? "" : " empty")}
      >
        {getResultsList()}
      </section>

      <Popup
        open={popupBeer !== null}
        closeOnDocumentClick
        onClose={() => setPopupBeer(null)}
      >
        <div className="modal">
          <a
            role="dialog-close-button"
            className="popup-close"
            onClick={() => setPopupBeer(null)}
          >
            &times;
          </a>

          {popupBeer !== null && (
            <div className="popup-content">
              <img
                src={popupBeer.image_url}
                alt={"Image of " + popupBeer.name}
                className="popup-image"
              />
              <h1 className="popup-title">{popupBeer.name}</h1>
              <div className="popup-sub">{`${popupBeer.abv}% · ${popupBeer.tagline}`}</div>
              <span className="popup-desc">{popupBeer.description}</span>

              <div className="popup-tips card">
                <h2>Tips</h2>
                <span>{popupBeer.brewers_tips}</span>
              </div>

              {popupBeer.food_pairing.length > 0 && (
                <div className="popup-food-pairings card">
                  <h2>Food Pairings</h2>
                  <ul>
                    {popupBeer.food_pairing.map((pairing, i) => (
                      <li key={pairing + i} className="popup-food">
                        {pairing}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          )}
        </div>
      </Popup>
    </div>
  );
}

export default App;
