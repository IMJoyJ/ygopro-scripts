--太鼓魔人テンテンテンポ
-- 效果：
-- 3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，自己场上的全部名字带有「魔人」的超量怪兽的攻击力上升500。这个效果在对方回合也能发动。
function c52558805.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为3的怪兽叠放2只以上
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择对方场上1只超量怪兽才能发动。把选择的怪兽1个超量素材取除，自己场上的全部名字带有「魔人」的超量怪兽的攻击力上升500。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52558805,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为非伤害步骤或伤害步骤但未进行伤害计算
	e1:SetCondition(aux.dscon)
	e1:SetCost(c52558805.atkcost)
	e1:SetTarget(c52558805.atktg)
	e1:SetOperation(c52558805.atkop)
	c:RegisterEffect(e1)
end
-- 支付效果代价：从自己场上取除1个超量素材
function c52558805.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，判断目标怪兽是否可以被取除1个超量素材
function c52558805.filter(c,tp)
	return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 设置效果目标：选择对方场上的1只超量怪兽作为对象
function c52558805.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c52558805.filter(chkc,tp) end
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		-- 检查自己是否能取除1个超量素材并确保对方场上存在满足条件的怪兽
		and Duel.IsExistingTarget(c52558805.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c52558805.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 过滤函数，筛选自己场上的表侧表示的超量怪兽（名字带有「魔人」）
function c52558805.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x6d)
end
-- 效果处理：将目标怪兽的1个超量素材取除，并使己方所有名字带「魔人」的超量怪兽攻击力上升500
function c52558805.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:GetOverlayCount()==0 then return end
	tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 筛选自己场上所有满足条件的超量怪兽
	local g=Duel.GetMatchingGroup(c52558805.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每个符合条件的怪兽添加攻击力上升500的效果
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
