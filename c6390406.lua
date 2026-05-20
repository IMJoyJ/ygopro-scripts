--竜破壊の証
-- 效果：
-- ①：从自己的卡组·墓地选1只「破坏之剑士」加入手卡。
function c6390406.initial_effect(c)
	-- ①：从自己的卡组·墓地选1只「破坏之剑士」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c6390406.target)
	e1:SetOperation(c6390406.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡名为「破坏之剑士」且可以加入手牌的卡
function c6390406.filter(c)
	return c:IsCode(78193831) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c6390406.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张可以加入手牌的「破坏之剑士」
	if chk==0 then return Duel.IsExistingMatchingCard(c6390406.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为：预计将1张卡组或墓地的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理的执行函数，用于将卡加入手牌并让对方确认
function c6390406.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组或墓地选择1张满足过滤条件且不受「王家长眠之谷」影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c6390406.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
