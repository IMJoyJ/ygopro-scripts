--王虎ワンフー
-- 效果：
-- ①：这张卡已在怪兽区域存在的状态，每次攻击力1400以下的怪兽召唤·特殊召唤发动。这张卡在场上表侧表示存在的场合，那些攻击力1400以下的怪兽破坏。
function c83986578.initial_effect(c)
	-- ①：这张卡已在怪兽区域存在的状态，每次攻击力1400以下的怪兽召唤·特殊召唤发动。这张卡在场上表侧表示存在的场合，那些攻击力1400以下的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83986578,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c83986578.condition)
	e1:SetTarget(c83986578.target)
	e1:SetOperation(c83986578.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且攻击力在1400以下的怪兽
function c83986578.cfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1400)
end
-- 触发条件：召唤·特殊召唤的怪兽中存在攻击力1400以下的怪兽，且不包含自身，且自身未被战斗破坏
function c83986578.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c83986578.cfilter,1,nil) and not eg:IsContains(e:GetHandler()) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果的目标处理：筛选出召唤·特殊召唤的攻击力1400以下的怪兽，并设置破坏的操作信息
function c83986578.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c83986578.cfilter,nil)
	-- 将本次召唤·特殊召唤的怪兽组设为效果处理的对象
	Duel.SetTargetCard(eg)
	-- 设置破坏的操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤条件：表侧表示、攻击力在1400以下且仍与该效果有关联的怪兽
function c83986578.filter(c,e)
	return c:IsFaceup() and c:IsAttackBelow(1400) and c:IsRelateToEffect(e)
end
-- 效果的处理：自身在场上表侧表示存在时，将那些仍满足条件的攻击力1400以下的怪兽破坏
function c83986578.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local g=eg:Filter(c83986578.filter,nil,e)
	if g:GetCount()>0 then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
