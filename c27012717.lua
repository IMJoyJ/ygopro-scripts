--猛虎モンフー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽的攻击力下降500。
-- ②：1回合1次，自己主要阶段才能发动。持有比这张卡低的攻击力的场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册两个效果：效果①为场上的怪兽攻击力下降500；效果②为1回合1次的破坏效果。
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。持有比这张卡低的攻击力的场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果①的目标过滤函数，确保只影响表侧表示且不是自身怪兽。
function s.atktg(e,c)
	return c:IsFaceup() and c~=e:GetHandler()
end
-- 效果②的破坏目标过滤函数，筛选攻击力低于指定值的表侧怪兽。
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 效果②的发动时处理函数，检查是否有满足条件的怪兽并设置操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	-- 判断是否有满足条件的怪兽，即攻击力低于自身攻击力的场上的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 获取所有满足条件的怪兽组合作为破坏目标。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 设置连锁操作信息，指定将要破坏的怪兽组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的发动处理函数，执行破坏操作。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取所有攻击力低于自身攻击力的场上的怪兽作为破坏对象。
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetAttack())
		-- 将符合条件的怪兽全部破坏，破坏原因为效果。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
