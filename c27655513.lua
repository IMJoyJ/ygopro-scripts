--スクリーチ
-- 效果：
-- 这张卡被战斗破坏的场合，从自己卡组选择2只水属性怪兽送去墓地。
function c27655513.initial_effect(c)
	-- 效果原文内容：这张卡被战斗破坏的场合，从自己卡组选择2只水属性怪兽送去墓地。
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
-- 规则层面作用：判断该卡是否因战斗破坏而被送去墓地
function c27655513.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面作用：过滤出卡组中满足条件的水属性怪兽（可送去墓地）
function c27655513.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGrave()
end
-- 规则层面作用：设置连锁处理信息，表明此效果会将2张卡从卡组送去墓地
function c27655513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置当前处理的连锁的操作信息，指定要处理的卡为2张卡，来自卡组
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 规则层面作用：检索满足条件的水属性怪兽组，并选择其中2张送去墓地
function c27655513.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取满足条件的水属性怪兽组（来自卡组）
	local g=Duel.GetMatchingGroup(c27655513.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>1 then
		-- 规则层面作用：向玩家发送提示信息，提示其选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 规则层面作用：将选中的卡以效果原因送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
