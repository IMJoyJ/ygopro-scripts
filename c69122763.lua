--守護霊のお守り
-- 效果：
-- 选择场上的表侧表示存在的1只怪兽。在回合结束前，每有1只自己墓地存在的怪兽，选择的那只怪兽的攻击力上升100。
function c69122763.initial_effect(c)
	-- 选择场上的表侧表示存在的1只怪兽。在回合结束前，每有1只自己墓地存在的怪兽，选择的那只怪兽的攻击力上升100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c69122763.target)
	e1:SetOperation(c69122763.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与合法性检测，判断场上是否存在表侧表示怪兽，且自己墓地是否存在怪兽
function c69122763.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查自己墓地是否存在至少1只怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，使选择的怪兽攻击力上升自己墓地怪兽数量×100的数值，直到回合结束
function c69122763.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 在回合结束前，每有1只自己墓地存在的怪兽，选择的那只怪兽的攻击力上升100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		-- 设置攻击力上升的值为自己墓地的怪兽数量乘以100
		e1:SetValue(Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)*100)
		tc:RegisterEffect(e1)
	end
end
