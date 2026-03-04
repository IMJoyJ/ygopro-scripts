--幻影騎士団カースド・ジャベリン
-- 效果：
-- 2星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这张卡有「幻影骑士团」卡在作为超量素材的场合，这个效果在对方回合也能发动）。那只怪兽直到回合结束时攻击力变成0，效果无效化。
function c12219047.initial_effect(c)
	-- 添加等级为2、需要2只怪兽作为素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这张卡有「幻影骑士团」卡在作为超量素材的场合，这个效果在对方回合也能发动）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12219047,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,12219047)
	e1:SetCondition(c12219047.condition1)
	e1:SetCost(c12219047.cost)
	e1:SetTarget(c12219047.target)
	e1:SetOperation(c12219047.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,0x21e0)
	e2:SetCondition(c12219047.condition2)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：当前怪兽没有「幻影骑士团」卡作为超量素材
function c12219047.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
end
-- 支付效果的代价：从自己场上移除1个超量素材
function c12219047.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选目标怪兽的过滤器函数
function c12219047.filter(c)
	-- 目标怪兽必须为表侧表示，且攻击力大于0或符合被无效化条件
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 设置效果的目标选择函数
function c12219047.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c12219047.filter(chkc) end
	-- 判断是否满足选择目标的条件：对方场上存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c12219047.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择一个对方场上的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c12219047.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果的执行函数
function c12219047.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁效果无效化并重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化（持续到结束阶段）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 将目标怪兽的攻击力变为0
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
	end
end
-- 第二个效果发动的条件函数
function c12219047.condition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
		-- 限制效果只能在伤害步骤前发动
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
