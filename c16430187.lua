--頼もしき守護者
-- 效果：
-- 场上表侧表示存在的1只怪兽的守备力直到结束阶段时上升700。
function c16430187.initial_effect(c)
	-- 效果发动条件：场上表侧表示存在的1只怪兽的守备力直到结束阶段时上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c16430187.target)
	e1:SetOperation(c16430187.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：选择表侧表示且守备力大于0的怪兽。
function c16430187.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 选择目标：选择场上1只表侧表示的怪兽作为效果对象。
function c16430187.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16430187.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(c16430187.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象。
	Duel.SelectTarget(tp,c16430187.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使选择的怪兽守备力上升700。
function c16430187.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的守备力直到结束阶段时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
