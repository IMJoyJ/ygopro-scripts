--スクリーチ
-- 效果：
-- 这张卡被战斗破坏的场合，从自己卡组选择2只水属性怪兽送去墓地。
function c27655513.initial_effect(c)
	-- 这张卡被战斗破坏的场合，从自己卡组选择2只水属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27655513,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c27655513.condition)
	e1:SetTarget(c27655513.target)
	e1:SetOperation(c27655513.operation)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：这张卡被战斗破坏（含有REASON_BATTLE原因）时，效果才能发动。
function c27655513.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义卡组内可供选择的卡片的过滤条件：必须是水属性怪兽，且能够被送去墓地。
function c27655513.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGrave()
end
-- 发动时点判定：无消耗且必定发动；随后登记效果处理信息，预定从自己卡组将2张卡送去墓地。
function c27655513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果为送去墓地效果，预定从自己卡组选择2张卡送去墓地，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从自己卡组挑选2只符合条件的水属性怪兽送去墓地；若卡组中符合条件的卡不足2张则不处理。
function c27655513.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件（水属性且可送墓）的怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c27655513.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>1 then
		-- 弹出选择提示，提示玩家从集合中选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将玩家选择的2张卡以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
