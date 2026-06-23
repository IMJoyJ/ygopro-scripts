--トライアングルパワー
-- 效果：
-- 自己场上所有以表侧表示存在的1星通常怪兽（衍生物除外）的原本的攻击力·守备力上升2000点。结束阶段时，自己场上存在的1星通常怪兽全部破坏。
function c32298781.initial_effect(c)
	-- 效果发动，将此卡作为永续魔法卡使用，改变攻击和防御力，触发自由时点
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32298781.target)
	e1:SetOperation(c32298781.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的1星通常怪兽（非衍生物）
function c32298781.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and tpe&TYPE_NORMAL~=0 and tpe&TYPE_TOKEN==0 and c:IsLevel(1)
end
-- 效果的发动目标函数，检查场上是否存在满足条件的怪兽
function c32298781.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若检查阶段未通过，则返回场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32298781.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果发动时执行的操作，为符合条件的怪兽增加攻击力和守备力
function c32298781.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c32298781.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 为怪兽增加攻击力2000点的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(batk+2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为怪兽增加守备力2000点的效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(bdef+2000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 注册结束阶段时触发的破坏效果
	local de=Effect.CreateEffect(e:GetHandler())
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_END)
	de:SetCountLimit(1)
	de:SetCondition(c32298781.descon)
	de:SetOperation(c32298781.desop)
	de:SetReset(RESET_PHASE+PHASE_END)
	-- 将破坏效果注册给玩家
	Duel.RegisterEffect(de,tp)
end
-- 用于判断是否在结束阶段时有符合条件的怪兽
function c32298781.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevel(1)
end
-- 结束阶段时的条件判断函数，检查场上是否存在满足条件的怪兽
function c32298781.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上存在满足条件的怪兽则返回true
	return Duel.IsExistingMatchingCard(c32298781.dfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段时执行的破坏操作，将符合条件的怪兽破坏
function c32298781.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c32298781.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 将满足条件的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
