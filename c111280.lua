--黒魔導強化
-- 效果：
-- ①：双方的场上·墓地的「黑魔术师」「黑魔术少女」数量的以下效果适用。
-- ●1只以上：选场上1只魔法师族·暗属性怪兽，那个攻击力直到回合结束时上升1000。
-- ●2只以上：这个回合，对方不能对应自己的魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动，自己场上的魔法·陷阱卡不会被对方的效果破坏。
-- ●3只以上：自己场上的魔法师族·暗属性怪兽直到回合结束时不受对方的效果影响。
function c111280.initial_effect(c)
	-- 将「黑魔术师」（46986414）和「黑魔术少女」（38033121）的卡号登记为这张卡上记载的卡名，使效果处理时能够识别并统计这些卡。
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
-- 过滤函数：判定卡片是否为表侧表示，且卡名属于「黑魔术师」或「黑魔术少女」，用于统计双方场上·墓地的这类卡数量。
function c111280.cfilter(c)
	return c:IsFaceup() and c:IsCode(46986414,38033121)
end
-- 效果发动条件：统计双方场上·墓地的「黑魔术师」「黑魔术少女」数量大于0，且处于允许发动的伤害步骤时点（伤害计算前）。
function c111280.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计双方场上·墓地中表侧表示且卡名为「黑魔术师」或「黑魔术少女」的卡的总数。
	local ct=Duel.GetMatchingGroupCount(c111280.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 返回条件判断结果：数量大于0，且满足伤害步骤中伤害计算前的发动限制。
	return ct>0 and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤函数：选择场上表侧表示的魔法师族·暗属性怪兽，作为攻击力上升或效果免疫的适用对象。
function c111280.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果发动时的目标合法性检查：计算「黑魔术师」「黑魔术少女」数量，若数量≤1则必须存在可选的目标怪兽才能发动；数量≥2时无此要求。
function c111280.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 在目标检查中再次统计双方场上·墓地中符合条件的「黑魔术师」「黑魔术少女」的数量。
		local ct=Duel.GetMatchingGroupCount(c111280.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		-- 若统计数量≤1，则要求场上存在至少1只表侧表示的魔法师族·暗属性怪兽，否则不能发动；数量≥2时允许直接发动。
		if ct<=1 then return Duel.IsExistingMatchingCard(c111280.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		return true
	end
end
-- 效果处理：根据「黑魔术师」「黑魔术少女」的数量ct，依次适用1只以上、2只以上、3只以上对应的效果，包括攻击力上升、封锁对方连锁、魔法·陷阱卡免疫破坏、怪兽效果免疫。
function c111280.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取双方场上·墓地中符合条件的「黑魔术师」「黑魔术少女」的集合，用于计算ct。
	local g=Duel.GetMatchingGroup(c111280.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=g:GetCount()
	if ct>=1 then
		-- 给出选择提示，提示玩家从场上选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家从双方场上选择1只表侧表示的魔法师族·暗属性怪兽，作为攻击力上升的效果对象。
		local g=Duel.SelectMatchingCard(tp,c111280.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 为选中的卡显示被选择动画，并记录这些卡为效果对象。
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
		-- ●2只以上：这个回合，对方不能对应自己的魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(c111280.chainop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将e2（监视连锁发动的持续效果）注册给当前玩家，使其在该回合内检测自己发动魔法·陷阱卡的时机。
		Duel.RegisterEffect(e2,tp)
		-- 自己场上的魔法·陷阱卡不会被对方的效果破坏。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e3:SetTargetRange(LOCATION_ONFIELD,0)
		e3:SetTarget(c111280.indtg)
		-- 设置e3的判定值为aux.indoval，即仅当效果的发动者为对方时，才使自己的魔法·陷阱卡不被该效果破坏。
		e3:SetValue(aux.indoval)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将e3（己方场上魔法·陷阱卡不受对方效果破坏的永续效果）注册到当前玩家，持续到回合结束。
		Duel.RegisterEffect(e3,tp)
	end
	if ct>=3 then
		-- 获取自己场上所有表侧表示的魔法师族·暗属性怪兽的集合，用于逐个附加“不受对方效果影响”的免疫效果。
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
-- 连锁监视函数：每当效果发动时，若发动者是己方且发动的是魔法·陷阱卡，则调用Duel.SetChainLimit来限制对方的连锁。
function c111280.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and ep==tp then
		-- 设置连锁限制，使后续连锁中只有当前发动魔法·陷阱卡的己方玩家可以进行连锁，对方不能对应发动效果。
		Duel.SetChainLimit(c111280.chainlm)
	end
end
-- 连锁限制条件：仅当尝试连锁的玩家与发动该魔法·陷阱卡的玩家相同（即只有自己）时才允许连锁，从而禁止对方连锁。
function c111280.chainlm(e,rp,tp)
	return tp==rp
end
-- e3的目标判定：判断卡片是否为魔法·陷阱卡，用于指定己方场上受保护的魔法·陷阱卡。
function c111280.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- e4的免疫判定：判断效果来源的持有者是否与免疫效果的所有者不同，即只免疫对方发动的效果。
function c111280.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
