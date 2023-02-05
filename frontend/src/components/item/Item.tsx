import { Beer } from "../../pages/app/App";
import "./Item.scss";

function Item(props: { beer: Beer; clickCb: (beer: Beer) => void }) {
  const beer = props.beer;
  return (
    <div className="item card hover" onClick={() => props.clickCb(beer)}>
      <img
        className="header-image"
        src={beer.image_url}
        alt={"Image of " + beer.name}
      />
      <div className="text-box">
        <span>{beer.name}</span>
        <span>{`${beer.abv}% · ${beer.tagline}`}</span>
      </div>
    </div>
  );
}

export default Item;
