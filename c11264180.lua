--TGX1－HL
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「科技属」的怪兽发动。选择的怪兽的攻击力·守备力变成一半，场上存在的1张魔法·陷阱卡破坏。
function c11264180.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「科技属」的怪兽发动。选择的怪兽的攻击力·守备力变成一半，场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c11264180.target)
	e1:SetOperation(c11264180.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且名字带有「科技属」。
function c11264180.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
-- 过滤函数，用于判断目标卡是否为魔法或陷阱卡。
function c11264180.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的处理目标函数，用于设置效果的目标和操作信息。
function c11264180.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11264180.filter(chkc) end
	-- 检查是否满足发动条件：自己场上存在至少1只名字带有「科技属」的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11264180.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否满足发动条件：场上存在至少1张魔法或陷阱卡。
		and Duel.IsExistingMatchingCard(c11264180.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家提示选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择满足条件的1只怪兽作为效果对象。
	Duel.SelectTarget(tp,c11264180.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取场上所有魔法或陷阱卡的集合。
	local dg=Duel.GetMatchingGroup(c11264180.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置效果操作信息，表明将要破坏1张魔法或陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 效果的处理函数，用于执行效果的发动和处理。
function c11264180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 将选择的怪兽攻击力变为原来的一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(math.ceil(tc:GetAttack()/2))
	tc:RegisterEffect(e1)
	-- 将选择的怪兽守备力变为原来的一半。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(math.ceil(tc:GetDefense()/2))
	tc:RegisterEffect(e2)
	-- 向玩家提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上1张魔法或陷阱卡作为破坏对象。
	local dg=Duel.SelectMatchingCard(tp,c11264180.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
	-- 将选择的魔法或陷阱卡破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
