--トライアングルパワー
-- 效果：
-- 自己场上所有以表侧表示存在的1星通常怪兽（衍生物除外）的原本的攻击力·守备力上升2000点。结束阶段时，自己场上存在的1星通常怪兽全部破坏。
function c32298781.initial_effect(c)
	-- 自己场上所有以表侧表示存在的1星通常怪兽（衍生物除外）的原本的攻击力·守备力上升2000点。结束阶段时，自己场上存在的1星通常怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32298781.target)
	e1:SetOperation(c32298781.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己场上表侧表示且等级为1的通常怪兽，并排除衍生物，作为本卡效果适用对象的过滤条件。
function c32298781.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and tpe&TYPE_NORMAL~=0 and tpe&TYPE_TOKEN==0 and c:IsLevel(1)
end
-- 效果发动时的目标判定函数，检查自己场上是否存在至少1只符合条件的怪兽，若存在则允许发动。
function c32298781.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点确认自己场上存在至少1只满足条件的1星通常怪兽（衍生物除外），满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c32298781.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理时，选出所有符合条件的怪兽，逐只将其原本攻击力、守备力各上升2000点；随后注册一个结束阶段触发的破坏效果，在结束阶段破坏这些怪兽。
function c32298781.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足过滤条件的表侧表示1星通常怪兽（衍生物除外）的集合。
	local g=Duel.GetMatchingGroup(c32298781.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 将所选怪兽的原本攻击力上升2000点。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(batk+2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 将所选怪兽的原本守备力上升2000点。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(bdef+2000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 结束阶段时，自己场上存在的1星通常怪兽全部破坏。
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_END)
	de:SetCountLimit(1)
	de:SetCondition(c32298781.descon)
	de:SetOperation(c32298781.desop)
	de:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段破坏效果注册给当前玩家，使其在结束阶段时按条件触发。
	Duel.RegisterEffect(de,tp)
end
-- 筛选结束阶段要破坏的怪兽：自己场上表侧表示且等级为1的通常怪兽。
function c32298781.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevel(1)
end
-- 结束阶段破坏效果的触发条件：若自己场上存在至少1只符合条件的1星通常怪兽，则执行破坏。
function c32298781.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示等级1的通常怪兽，作为破坏效果的发动条件。
	return Duel.IsExistingMatchingCard(c32298781.dfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段破坏效果的实际处理：获取所有符合条件的怪兽并全部破坏。
function c32298781.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且等级1的通常怪兽的集合。
	local g=Duel.GetMatchingGroup(c32298781.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 以效果原因破坏这些通常怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
