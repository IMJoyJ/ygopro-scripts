--魔法石の採掘
-- 效果：
-- ①：丢弃2张手卡，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
function c98494543.initial_effect(c)
	-- ①：丢弃2张手卡，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c98494543.cost)
	e1:SetTarget(c98494543.target)
	e1:SetOperation(c98494543.operation)
	c:RegisterEffect(e1)
end
-- 检查并执行发动代价：丢弃2张手牌
function c98494543.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少2张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 玩家选择并丢弃2张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：属于魔法卡且能加入手牌
function c98494543.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检查发动条件，选择墓地的魔法卡作为对象，并设置操作信息
function c98494543.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c98494543.filter(chkc) end
	-- 检查自己墓地是否存在至少1张可以加入手牌的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c98494543.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送提示信息，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,c98494543.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将作为对象的魔法卡加入手牌
function c98494543.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
