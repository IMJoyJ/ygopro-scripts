--炎熱伝導場
-- 效果：
-- ①：从卡组把2只「熔岩」怪兽送去墓地。
function c72142276.initial_effect(c)
	-- ①：从卡组把2只「熔岩」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c72142276.target)
	e1:SetOperation(c72142276.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中属于「熔岩」系列、是怪兽卡且能送去墓地的卡片
function c72142276.tgfilter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动的目标检查与操作信息设置
function c72142276.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少2张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c72142276.tgfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置效果处理信息为将卡组的2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择2只「熔岩」怪兽送去墓地
function c72142276.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c72142276.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=2 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的卡片因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
