--おろかな埋葬
-- 效果：
-- ①：从卡组把1只怪兽送去墓地。
function c81439173.initial_effect(c)
	-- ①：从卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81439173.target)
	e1:SetOperation(c81439173.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中可以送去墓地的怪兽卡
function c81439173.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动时的合法性检测与操作信息设置
function c81439173.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在至少1张可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81439173.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只怪兽送去墓地
function c81439173.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从己方卡组选择1张满足过滤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c81439173.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
