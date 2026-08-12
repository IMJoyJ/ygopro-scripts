--サウザンドエナジー
-- 效果：
-- 自己场上所有以表侧表示存在的2星通常怪兽（衍生物除外）的原本的攻击力·守备力上升1000点。结束阶段时，自己场上存在的2星通常怪兽全部破坏。
function c5703682.initial_effect(c)
	-- 自己场上所有以表侧表示存在的2星通常怪兽（衍生物除外）的原本的攻击力·守备力上升1000点。结束阶段时，自己场上存在的2星通常怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5703682.target)
	e1:SetOperation(c5703682.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的2星通常怪兽（非衍生物）
function c5703682.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0 and c:IsLevel(2)
end
-- 效果发动的靶向/合法性检查
function c5703682.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的2星通常怪兽（非衍生物）
	if chk==0 then return Duel.IsExistingMatchingCard(c5703682.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：使符合条件的怪兽原本攻防上升1000，并注册结束阶段的破坏效果
function c5703682.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的2星通常怪兽（非衍生物）
	local g=Duel.GetMatchingGroup(c5703682.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 自己场上所有以表侧表示存在的2星通常怪兽（衍生物除外）的原本的攻击力·守备力上升1000点。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(batk+1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(bdef+1000)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 结束阶段时，自己场上存在的2星通常怪兽全部破坏。
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_END)
	de:SetCountLimit(1)
	de:SetCondition(c5703682.descon)
	de:SetOperation(c5703682.desop)
	de:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段发动破坏效果的全局延迟效果
	Duel.RegisterEffect(de,tp)
end
-- 过滤条件：自己场上表侧表示的2星通常怪兽（用于结束阶段破坏）
function c5703682.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevel(2)
end
-- 结束阶段破坏效果的发动条件
function c5703682.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的2星通常怪兽
	return Duel.IsExistingMatchingCard(c5703682.dfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段破坏效果的处理
function c5703682.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的2星通常怪兽
	local g=Duel.GetMatchingGroup(c5703682.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 因效果破坏这些怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
