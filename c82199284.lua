--霞の谷のファルコン
-- 效果：
-- 这张卡若不让自己场上存在的1张卡回到手卡则不能攻击宣言。
function c82199284.initial_effect(c)
	-- 这张卡若不让自己场上存在的1张卡回到手卡则不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetCost(c82199284.atcost)
	e1:SetOperation(c82199284.atop)
	c:RegisterEffect(e1)
end
-- 定义攻击宣言时代价的检测函数
function c82199284.atcost(e,c,tp)
	-- 检查自己场上是否存在至少1张可以作为代价返回手牌的卡（不包括自身）
	return Duel.IsExistingMatchingCard(Card.IsAbleToHandAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 定义攻击宣言时代价的具体执行操作
function c82199284.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己场上1张可以作为代价返回手牌的卡（不包括自身）
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHandAsCost,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选择的卡作为代价送回手牌
	Duel.SendtoHand(g,nil,REASON_COST)
end
