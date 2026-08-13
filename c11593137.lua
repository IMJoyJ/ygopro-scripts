--混沌の落とし穴
-- 效果：
-- 支付2000基本分发动。光属性以及暗属性怪兽的召唤·反转召唤·特殊召唤无效并从游戏中除外。
function c11593137.initial_effect(c)
	-- 支付2000基本分发动。光属性以及暗属性怪兽的召唤·反转召唤·特殊召唤无效并从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c11593137.condition)
	e1:SetCost(c11593137.cost)
	e1:SetTarget(c11593137.target)
	e1:SetOperation(c11593137.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 过滤出同时满足“光属性或暗属性”且可被除外的怪兽。
function c11593137.filter(c)
	return c:IsAttribute(0x30) and c:IsAbleToRemove()
end
-- 效果的发动条件：当前没有其他连锁处理，且本次召唤·反转召唤·特殊召唤的怪兽组中存在符合条件的怪兽。
function c11593137.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件成立：无连锁处理中（召唤时点）且召唤的怪兽中存在至少1只光/暗属性且可除外的怪兽。
	return aux.NegateSummonCondition() and eg:IsExists(c11593137.filter,1,nil)
end
-- 发动代价函数：需要支付2000基本分才能发动，并实际支付。
function c11593137.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认玩家能否支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- 发动时目标处理：筛选本次召唤中符合条件的怪兽，并登记无效召唤与除外的操作信息。
function c11593137.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标合法性检查阶段，确认玩家当前可以进行除外操作（不存在禁止除外的限制）。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	local g=eg:Filter(c11593137.filter,nil)
	-- 将无效召唤的分类及目标怪兽组（数量为g的怪兽数）写入连锁操作信息，便于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 将除外的分类及目标怪兽组（数量为g的怪兽数）写入连锁操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理时：重新筛选本次召唤中符合条件的怪兽，执行召唤无效并除外。
function c11593137.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c11593137.filter,nil)
	-- 使筛选出的怪兽的召唤无效（该次召唤被无效，怪兽不会上场）。
	Duel.NegateSummon(g)
	-- 将筛选出的怪兽以表侧表示从游戏中除外，除外原因为效果。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
