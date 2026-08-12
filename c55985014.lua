--ミラクル・キッズ
-- 效果：
-- 直到结束阶段前，对方的1只怪兽的攻击力下降自己墓地存在的「英雄小子」的数量×400的数值。
function c55985014.initial_effect(c)
	-- 直到结束阶段前，对方的1只怪兽的攻击力下降自己墓地存在的「英雄小子」的数量×400的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动的条件为不在伤害计算后（即非伤害阶段或伤害计算前）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c55985014.target)
	e1:SetOperation(c55985014.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与合法性检查：检查自己墓地是否存在「英雄小子」，且对方场上是否存在表侧表示的怪兽
function c55985014.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查自己墓地是否存在至少1张「英雄小子」
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,32679370)
		-- 并且对方场上存在至少1只表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取选择的对象，计算自己墓地「英雄小子」的数量，并使该对象的攻击力下降对应数值直到结束阶段
function c55985014.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 计算自己墓地存在的「英雄小子」的数量×400的数值
	local val=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,32679370)*400
	if val>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到结束阶段前，对方的1只怪兽的攻击力下降自己墓地存在的「英雄小子」的数量×400的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-val)
		tc:RegisterEffect(e1)
	end
end
