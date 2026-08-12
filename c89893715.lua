--ラヴァルの炎車回し
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组选择2只名字带有「熔岩」的怪兽送去墓地。
function c89893715.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组选择2只名字带有「熔岩」的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89893715,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c89893715.condition)
	e1:SetTarget(c89893715.target)
	e1:SetOperation(c89893715.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否在墓地，且是否因战斗破坏而送去墓地
function c89893715.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中属于怪兽且可以送去墓地的「熔岩」卡片
function c89893715.filter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动的目标检查与操作信息设置，确认卡组中存在至少2只可送去墓地的「熔岩」怪兽
function c89893715.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组中是否存在至少2只满足条件的「熔岩」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89893715.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置操作信息，表明此效果会将卡组的2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择2只「熔岩」怪兽送去墓地
function c89893715.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「熔岩」怪兽
	local g=Duel.GetMatchingGroup(c89893715.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()<2 then return end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将选中的怪兽因效果送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
