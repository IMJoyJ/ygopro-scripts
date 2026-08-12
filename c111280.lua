--黒魔導強化
-- 效果：
-- ①：双方的场上·墓地的「黑魔术师」「黑魔术少女」数量的以下效果适用。
-- ●1只以上：选场上1只魔法师族·暗属性怪兽，那个攻击力直到回合结束时上升1000。
-- ●2只以上：这个回合，对方不能对应自己的魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动，自己场上的魔法·陷阱卡不会被对方的效果破坏。
-- ●3只以上：自己场上的魔法师族·暗属性怪兽直到回合结束时不受对方的效果影响。
function c111280.initial_effect(c)
	-- 为卡片注册关联的黑魔术师和黑魔术少女的卡片代码，用于后续效果判断
	aux.AddCodeList(c,46986414,38033121)
	-- ①：双方的场上·墓地的「黑魔术师」「黑魔术少女」数量的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c111280.condition)
	e1:SetTarget(c111280.target)
	e1:SetOperation(c111280.activate)
	c:RegisterEffect(e1)
end
-- 用于过滤场上或墓地中的黑魔术师或黑魔术少女的卡片
function c111280.cfilter(c)
	return c:IsFaceup() and c:IsCode(46986414,38033121)
end
-- 判断效果发动条件，统计双方场上和墓地中的黑魔术师/黑魔术少女数量
function c111280.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计双方场上和墓地中的黑魔术师或黑魔术少女的数量
	local ct=Duel.GetMatchingGroupCount(c111280.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 当数量大于0且满足伤害步骤限制条件时效果可以发动
	return ct>0 and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 用于过滤场上魔法师族暗属性的怪兽
function c111280.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 设置效果的发动目标，根据黑魔术师/黑魔术少女数量决定是否需要选择目标
function c111280.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 统计双方场上和墓地中的黑魔术师或黑魔术少女的数量
		local ct=Duel.GetMatchingGroupCount(c111280.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		-- 当数量不超过1时，检查是否场上存在魔法师族暗属性怪兽
		if ct<=1 then return Duel.IsExistingMatchingCard(c111280.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		return true
	end
end
-- 效果发动时执行的主要处理函数
function c111280.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上和墓地中的黑魔术师或黑魔术少女的卡片组
	local g=Duel.GetMatchingGroup(c111280.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=g:GetCount()
	if ct>=1 then
		-- 提示玩家选择目标怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		-- 选择场上一只魔法师族暗属性怪兽作为目标
		local g=Duel.SelectMatchingCard(tp,c111280.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示所选怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			-- ●1只以上：选场上1只魔法师族·暗属性怪兽，那个攻击力直到回合结束时上升1000。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1000)
			tc:RegisterEffect(e1)
		end
	end
	if ct>=2 then
		-- ●2只以上：这个回合，对方不能对应自己的魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动，自己场上的魔法·陷阱卡不会被对方的效果破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(c111280.chainop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将连锁限制效果注册给玩家
		Duel.RegisterEffect(e2,tp)
		-- ●3只以上：自己场上的魔法师族·暗属性怪兽直到回合结束时不受对方的效果影响。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e3:SetTargetRange(LOCATION_ONFIELD,0)
		e3:SetTarget(c111280.indtg)
		-- 设置效果值为aux.indoval函数，用于判断是否不会被对方效果破坏
		e3:SetValue(aux.indoval)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e3,tp)
	end
	if ct>=3 then
		-- 获取自己场上的魔法师族暗属性怪兽
		local g=Duel.GetMatchingGroup(c111280.filter,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- ●3只以上：自己场上的魔法师族·暗属性怪兽直到回合结束时不受对方的效果影响。
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_IMMUNE_EFFECT)
			e4:SetValue(c111280.efilter)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e4:SetOwnerPlayer(tp)
			tc:RegisterEffect(e4)
			tc=g:GetNext()
		end
	end
end
-- 连锁处理函数，用于限制对方不能对应魔法陷阱卡发动的效果
function c111280.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and ep==tp then
		-- 设置连锁限制条件，禁止对方在该回合对己方魔法陷阱发动效果
		Duel.SetChainLimit(c111280.chainlm)
	end
end
-- 连锁限制函数，判断是否为同一玩家发动的效果
function c111280.chainlm(e,rp,tp)
	return tp==rp
end
-- 用于判断目标是否为魔法或陷阱卡
function c111280.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 用于判断效果是否来自对方
function c111280.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
