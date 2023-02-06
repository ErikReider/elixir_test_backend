import {
  fireEvent,
  render,
  screen,
  waitFor,
  getByRole,
  getByText,
} from "@testing-library/react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import Mocks from "../../mockData";
import App from "./App";

function render_app() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/">
          <Route index element={<App />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

let windowFetchSpy: jest.SpyInstance;

beforeEach(() => {
  windowFetchSpy = jest
    .spyOn(window, "fetch")
    .mockImplementation(async (url, _fetch_params) => {
      // Wait for 100ms
      await new Promise((resolve) => setTimeout(resolve, 100));
      // No real pattern matching in JS... :(
      let response = Mocks.MOCK_RESPONSE_HAS_NEXT_10;
      if (url.toString().match(new RegExp(/query=SHOW_ERROR/))?.[0]) {
        response = Mocks.MOCK_RESPONSE_ERROR;
      } else if (url.toString().match(new RegExp(/page_nr=3/))?.[0]) {
        response = Mocks.MOCK_RESPONSE_NO_NEXT_3;
      } else if (url.toString().match(new RegExp(/page_nr=1000/))?.[0]) {
        response = Mocks.MOCK_RESPONSE_EMPTY;
      }
      return {
        ok: true,
        status: 200,
        headers: new Headers({ "content-type": "application/json" }),
        json: async () => response,
      } as Response;
    });
});

afterEach(() => {
  jest.restoreAllMocks();
});

test("renders all buttons and inputs", () => {
  render(render_app());

  const searchBox = screen.getByRole("searchbox") as HTMLInputElement;
  expect(searchBox).toBeInTheDocument();
  expect(searchBox).toHaveValue("");
  expect(searchBox.placeholder).toBe("Search for beers");

  const searchButton = screen.getByRole("button") as HTMLButtonElement;
  expect(searchButton).toBeInTheDocument();
  expect(searchButton).toHaveValue("Search 🍺");

  const searchSpan = screen.getByText(/search for beers/i);
  expect(searchSpan).toBeInTheDocument();
});

describe("Navigates with the correct URL parameters", () => {
  test("should not navigate with queries when search box is empty", () => {
    Mocks.mockLocation();

    render(render_app());

    const searchBox = screen.getByRole("searchbox") as HTMLInputElement;
    const searchButton = screen.getByRole("button") as HTMLButtonElement;

    fireEvent.change(searchBox, { target: { value: "" } });

    fireEvent.click(searchButton);

    expect(window.location.assign).toBeCalledWith("http://localhost/");
  });

  test(`Search for ${Mocks.MOCK_QUERY} on page 1`, () => {
    Mocks.mockLocation();

    render(render_app());

    const searchBox = screen.getByRole("searchbox") as HTMLInputElement;
    const searchButton = screen.getByRole("button") as HTMLButtonElement;

    fireEvent.change(searchBox, { target: { value: `${Mocks.MOCK_QUERY}` } });

    fireEvent.click(searchButton);

    expect(window.location.assign).toBeCalledWith(
      `http://localhost/?query=${Mocks.MOCK_QUERY}&page_nr=1`
    );
  });

  test(`Search for ${Mocks.MOCK_QUERY} on page 2`, () => {
    Mocks.mockLocation();

    render(render_app());

    const searchBox = screen.getByRole("searchbox") as HTMLInputElement;
    const searchButton = screen.getByRole("button") as HTMLButtonElement;

    fireEvent.change(searchBox, { target: { value: `${Mocks.MOCK_QUERY}` } });

    fireEvent.click(searchButton);

    expect(window.location.assign).toBeCalledWith(
      `http://localhost/?query=${Mocks.MOCK_QUERY}&page_nr=1`
    );
  });
});

test("Search includes query when searching", async () => {
  Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=1`);

  render(render_app());

  const searchBox = screen.getByRole("searchbox") as HTMLInputElement;
  expect(searchBox).toBeInTheDocument();
  expect(searchBox).toHaveValue(Mocks.MOCK_QUERY);
  expect(searchBox.placeholder).toBe("Search for beers");
});

describe("Querying DB", () => {
  test(`${Mocks.MOCK_QUERY} on page 0 should default to page 1`, async () => {
    Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=0`);

    render(render_app());

    expect(windowFetchSpy).toHaveBeenCalled();
    expect(windowFetchSpy).toHaveBeenCalledWith(
      `http://localhost:8080?query=${Mocks.MOCK_QUERY}&page_nr=1`,
      { headers: { accepts: "application/json" }, method: "GET" }
    );

    await waitFor(() => {
      const items = window.document.getElementsByClassName("item card hover");
      expect(items.length).toBe(10);

      const buttons = screen.getAllByRole("button");
      expect(buttons).toHaveLength(3);

      expect(screen.getByText("‹")).toBeDisabled();
      expect(screen.getByText("›")).not.toBeDisabled();
    });
  });

  test(`${Mocks.MOCK_QUERY} on page 1000 should result in no beers`, async () => {
    Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=1000`);

    render(render_app());

    expect(windowFetchSpy).toHaveBeenCalled();
    expect(windowFetchSpy).toHaveBeenCalledWith(
      `http://localhost:8080?query=${Mocks.MOCK_QUERY}&page_nr=1000`,
      { headers: { accepts: "application/json" }, method: "GET" }
    );

    await waitFor(() => {
      expect(screen.getByText("No beers found...")).toBeInTheDocument();

      const items = window.document.getElementsByClassName("item card hover");
      expect(items.length).toBe(0);

      const buttons = screen.getAllByRole("button");
      expect(buttons).toHaveLength(1);
    });
  });

  test(`for ${Mocks.MOCK_QUERY} on page 1`, async () => {
    Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=1`);

    render(render_app());

    expect(windowFetchSpy).toHaveBeenCalled();
    expect(windowFetchSpy).toHaveBeenCalledWith(
      `http://localhost:8080?query=${Mocks.MOCK_QUERY}&page_nr=1`,
      { headers: { accepts: "application/json" }, method: "GET" }
    );

    await waitFor(() => {
      const items = window.document.getElementsByClassName("item card hover");
      expect(items.length).toBe(10);

      const buttons = screen.getAllByRole("button");
      expect(buttons).toHaveLength(3);

      expect(screen.getByText("‹")).toBeDisabled();
      expect(screen.getByText("›")).not.toBeDisabled();
    });
  });

  test(`for ${Mocks.MOCK_QUERY} on page 2`, async () => {
    Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=2`);

    render(render_app());

    expect(windowFetchSpy).toHaveBeenCalled();
    expect(windowFetchSpy).toHaveBeenCalledWith(
      `http://localhost:8080?query=${Mocks.MOCK_QUERY}&page_nr=2`,
      { headers: { accepts: "application/json" }, method: "GET" }
    );

    await waitFor(() => {
      const items = window.document.getElementsByClassName("item card hover");
      expect(items).toHaveLength(10);

      const buttons = screen.getAllByRole("button");
      expect(buttons).toHaveLength(3);

      expect(screen.getByText("‹")).not.toBeDisabled();
      expect(screen.getByText("›")).not.toBeDisabled();
    });
  });

  test(`for ${Mocks.MOCK_QUERY} on page 3`, async () => {
    Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=3`);

    render(render_app());

    expect(windowFetchSpy).toHaveBeenCalled();
    expect(windowFetchSpy).toHaveBeenCalledWith(
      `http://localhost:8080?query=${Mocks.MOCK_QUERY}&page_nr=3`,
      { headers: { accepts: "application/json" }, method: "GET" }
    );

    await waitFor(() => {
      const items = window.document.getElementsByClassName("item card hover");
      expect(items).toHaveLength(3);

      const buttons = screen.getAllByRole("button");
      expect(buttons).toHaveLength(3);

      expect(screen.getByText("‹")).not.toBeDisabled();
      expect(screen.getByText("›")).toBeDisabled();
    });
  });
});

describe("Testing of Popup", () => {
  async function queryAndClick() {
    Mocks.mockLocation(`?query=${Mocks.MOCK_QUERY}&page_nr=1`);

    render(render_app());

    expect(windowFetchSpy).toHaveBeenCalled();
    expect(windowFetchSpy).toHaveBeenCalledWith(
      `http://localhost:8080?query=${Mocks.MOCK_QUERY}&page_nr=1`,
      { headers: { accepts: "application/json" }, method: "GET" }
    );

    await waitFor(() => {
      const items = window.document.getElementsByClassName("item card hover");
      expect(items.length).toBe(10);

      const buttons = screen.getAllByRole("button");
      expect(buttons).toHaveLength(3);

      expect(screen.getByText("‹")).toBeDisabled();
      expect(screen.getByText("›")).not.toBeDisabled();
    });

    const item = document.getElementsByClassName("item card hover")[0];
    expect(item).toContainHTML(
      `<img class="header-image" src="https://images.punkapi.com/v2/2.png" alt="Image of Trashy Blonde"><div class="text-box"><span>Trashy Blonde</span><span>4.1% · You Know You Shouldn't</span></div>`
    );
    fireEvent.click(item);
  }

  test("displaying correct content", async () => {
    await queryAndClick();

    // Popup
    const popup = document.getElementById("popup-root") as HTMLElement;
    expect(popup).toBeInTheDocument();
    // Image
    const img = getByRole(popup, "img") as HTMLImageElement;
    expect(img).toBeInTheDocument();
    expect(img.src).toBe("https://images.punkapi.com/v2/2.png");
    expect(img.alt).toBe("Image of Trashy Blonde");
    // Name
    expect(getByText(popup, "Trashy Blonde")).toBeInTheDocument();
    // Subtitle
    const subtitle = "4.1% · You Know You Shouldn't";
    expect(getByText(popup, subtitle)).toBeInTheDocument();
    // Description
    expect(getByText(popup, "Desc...")).toBeInTheDocument();
    // Tips
    expect(getByText(popup, "Tips...")).toBeInTheDocument();
    // Food pairing 1
    expect(getByText(popup, "Pairing 1...")).toBeInTheDocument();
    // Food pairing 2
    expect(getByText(popup, "Pairing 2...")).toBeInTheDocument();
  });

  test("Closes on close button click", async () => {
    await queryAndClick();

    const popup_content = screen.getByRole("dialog");
    expect(popup_content).toBeInTheDocument();

    const close_button = screen.getByRole("dialog-close-button");
    expect(close_button).toBeInTheDocument();
    fireEvent.click(close_button);

    expect(popup_content).not.toBeInTheDocument();
  });
});

test("should display error on error", async () => {
  Mocks.mockLocation(`?query=SHOW_ERROR&page_nr=1`);

  render(render_app());

  expect(windowFetchSpy).toHaveBeenCalled();
  expect(windowFetchSpy).toHaveBeenCalledWith(
    `http://localhost:8080?query=SHOW_ERROR&page_nr=1`,
    { headers: { accepts: "application/json" }, method: "GET" }
  );

  await waitFor(() => {
    const error = screen.getByRole("error-msg");
    expect(error).toBeInTheDocument();
    expect(error).toHaveTextContent("Test error message...");

    const buttons = screen.getAllByRole("button");
    expect(buttons).toHaveLength(1);
  });
});

