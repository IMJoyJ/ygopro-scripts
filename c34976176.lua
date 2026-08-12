--BF－雪撃のチヌーク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有暗属性同调怪兽存在的场合，这个效果在对方回合也能发动）。从额外卡组把1只「黑羽」同调怪兽或「黑翼龙」送去墓地，作为对象的怪兽直到回合结束时攻击力下降700，效果无效化。
function c34976176.initial_effect(c)
	-- 记录该卡牌效果中涉及的其他卡名（黑翼龙）
	aux.AddCodeList(c,9012916)
	-- ①：把手卡·场上的这张卡送去墓地，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有暗属性同调怪兽存在的场合，这个效果在对方回合也能发动）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34976176,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,34976176)
	e1:SetCondition(c34976176.discon1)
	e1:SetCost(c34976176.discost)
	e1:SetTarget(c34976176.distg)
	e1:SetOperation(c34976176.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c34976176.discon2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在暗属性同调怪兽
function c34976176.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果发动的条件1：当自己场上没有暗属性同调怪兽时，效果可以发动
function c34976176.discon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当自己场上没有暗属性同调怪兽时，效果可以发动
	return not Duel.IsExistingMatchingCard(c34976176.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动的条件2：当自己场上存在暗属性同调怪兽时，效果可以在对方回合发动
function c34976176.discon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当自己场上存在暗属性同调怪兽时，效果可以在对方回合发动
	return Duel.IsExistingMatchingCard(c34976176.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 限制效果只能在伤害计算前发动
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果的费用：将此卡送入墓地
function c34976176.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于判断目标怪兽是否可以被效果影响
function c34976176.filter(c)
	-- 目标怪兽必须表侧表示且满足被无效化条件或攻击力大于0
	return c:IsFaceup() and (aux.NegateMonsterFilter(c) or c:GetAttack()>0)
end
-- 过滤函数，用于选择可以从额外卡组送去墓地的「黑羽」同调怪兽或「黑翼龙」
function c34976176.tgfilter(c)
	return c:IsAbleToGrave() and ((c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO)) or c:IsCode(9012916))
end
-- 设置效果的目标和条件：选择对方场上一只表侧表示怪兽为目标，并确认额外卡组有符合条件的怪兽
function c34976176.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c34976176.filter(chkc) end
	-- 检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c34976176.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己额外卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c34976176.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上一只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,c34976176.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：准备将一张额外卡组的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果的处理函数：执行效果的最终处理
function c34976176.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择一只符合条件的怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c34976176.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 确认选择的怪兽成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使对象怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使对象怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 使对象怪兽攻击力下降700
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(-700)
		tc:RegisterEffect(e3)
	end
end
