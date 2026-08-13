--恐撃
-- 效果：
-- ①：把自己墓地2只怪兽除外，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
function c51099515.initial_effect(c)
	-- ①：把自己墓地2只怪兽除外，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤内且尚未进行伤害计算，即只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c51099515.cost)
	e1:SetTarget(c51099515.target)
	e1:SetOperation(c51099515.activate)
	c:RegisterEffect(e1)
end
-- 定义代价过滤函数：满足怪兽类型且可以作为代价除外。
function c51099515.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价：从自己墓地选择2只怪兽表侧表示除外。
function c51099515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：确认自己墓地存在至少2只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c51099515.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示选择要除外的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只符合条件的怪兽作为代价。
	local cg=Duel.SelectMatchingCard(tp,c51099515.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2只怪兽表侧表示除外，处理代价。
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 定义对象过滤函数：表侧攻击表示且当前攻击力大于0。
function c51099515.tfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:GetAttack()>0
end
-- 效果发动时的取对象处理：选择场上1只表侧攻击表示且攻击力大于0的怪兽作为对象。
function c51099515.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51099515.tfilter(chkc) end
	-- 发动前对象检查：确认场上存在至少1只符合条件的表侧攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51099515.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择表侧表示卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的表侧攻击表示怪兽作为效果对象。
	Duel.SelectTarget(tp,c51099515.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象怪兽仍表侧表示且与效果关联，将其攻击力直到回合结束时变成0。
function c51099515.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
