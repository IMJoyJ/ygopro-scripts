--連鎖旋風
-- 效果：
-- 魔法·陷阱·效果怪兽的效果让场上存在的卡破坏时，选择场上存在的2张魔法·陷阱卡才能发动。选择的卡破坏。
function c22205600.initial_effect(c)
	-- 效果原文内容：魔法·陷阱·效果怪兽的效果让场上存在的卡破坏时，选择场上存在的2张魔法·陷阱卡才能发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c22205600.condition)
	e1:SetTarget(c22205600.target)
	e1:SetOperation(c22205600.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：过滤满足破坏原因、效果破坏、且之前在场上的卡
function c22205600.cfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面作用：判断是否有满足条件的卡被破坏
function c22205600.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22205600.cfilter,1,nil)
end
-- 规则层面作用：筛选场上魔法或陷阱类型的卡
function c22205600.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面作用：设置连锁旋风的发动目标选择逻辑
function c22205600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c22205600.filter(chkc) and chkc~=e:GetHandler() end
	-- 规则层面作用：检查是否满足发动条件，即场上存在至少2张魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c22205600.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上满足条件的2张魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c22205600.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	-- 规则层面作用：设置本次连锁操作的信息，包括破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 规则层面作用：执行连锁旋风的效果，将选中的卡破坏
function c22205600.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取连锁中被选择的目标卡，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 规则层面作用：以效果破坏的方式将目标卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
