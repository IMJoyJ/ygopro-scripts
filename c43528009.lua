--星の金貨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选自己2张手卡加入对方手卡。那之后，自己从卡组抽2张。
function c43528009.initial_effect(c)
	-- 创建效果，设置为魔法卡发动，自由时点，发动次数限制为1次，目标函数为c43528009.target，发动效果为c43528009.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43528009+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43528009.target)
	e1:SetOperation(c43528009.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动条件判断，检查自己手牌是否至少有2张且自己可以抽2张卡
function c43528009.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己手牌至少有2张且可以抽2张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,2,e:GetHandler()) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置发动效果的操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时执行的操作函数，包括选择手牌、移动手牌、洗牌、抽卡等
function c43528009.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入对方手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43528009,0))  --"请选择要加入对方手卡的卡"
	-- 选择自己手牌中2张卡作为目标
	local ag=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,2,2,nil)
	if ag:GetCount()==2 then
		-- 将选中的卡送入对方手卡
		Duel.SendtoHand(ag,1-tp,REASON_EFFECT)
		-- 确认玩家看到被送入对方手卡的卡
		Duel.ConfirmCards(tp,ag)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-tp)
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 自己从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
