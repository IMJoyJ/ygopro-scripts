--太鼓魔人テンテンテンポ
-- 效果：
-- 3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，自己场上的全部名字带有「魔人」的超量怪兽的攻击力上升500。这个效果在对方回合也能发动。
function c52558805.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意3星怪兽2只作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 对应效果原文：『1回合1次，把这张卡1个超量素材取除，选择对方场上1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，自己场上的全部名字带有「魔人」的超量怪兽的攻击力上升500。这个效果在对方回合也能发动。』此处创建并注册该诱发即时效果及其代价、目标、处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52558805,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件：限制在伤害步骤时只能在伤害计算前发动（aux.dscon为伤害步骤限制条件），其余阶段可自由发动；配合二速效果使对方回合也能发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c52558805.atkcost)
	e1:SetTarget(c52558805.atktg)
	e1:SetOperation(c52558805.atkop)
	c:RegisterEffect(e1)
end
-- 发动代价：确认这张卡有1个超量素材可去除；实际处理时去除这张卡的1个超量素材作为代价（REASON_COST）。
function c52558805.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标过滤：对方场上的超量怪兽能被去除1个超量素材（REASON_EFFECT）。
function c52558805.filter(c,tp)
	return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 取对象目标：确认自己这张卡仍能去除1个超量素材（REASON_EFFECT），并且对方场上有满足条件的超量怪兽可选；若指定对象则检查该对象是否在对方怪兽区且满足条件。
function c52558805.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c52558805.filter(chkc,tp) end
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		-- 无指定对象时，额外确认对方场上存在至少1只满足条件的超量怪兽作为可选目标。
		and Duel.IsExistingTarget(c52558805.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 弹出选择提示：让玩家选择一张表侧表示的卡（此处用于选择对方场上1只超量怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只满足过滤条件的超量怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c52558805.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 攻击力上升对象过滤：表侧表示的超量怪兽且卡名含有「魔人」（SetCard 0x6d）。
function c52558805.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x6d)
end
-- 效果处理：先去除对象超量怪兽的1个素材；再获取自己场上全部满足条件的「魔人」超量怪兽，给每只赋予攻击力上升500的永续效果（不可被无效，通常离场/回手等标准重置）。
function c52558805.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡（对方场上被取除素材的超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:GetOverlayCount()==0 then return end
	tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 获取自己场上全部表侧表示的名字带有「魔人」的超量怪兽集合，用于后续提升攻击力。
	local g=Duel.GetMatchingGroup(c52558805.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对应效果原文：『自己场上的全部名字带有「魔人」的超量怪兽的攻击力上升500。』即给每只符合条件的怪兽注册一个攻击力上升500的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
