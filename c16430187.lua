--頼もしき守護者
-- 效果：
-- 场上表侧表示存在的1只怪兽的守备力直到结束阶段时上升700。
function c16430187.initial_effect(c)
	-- 场上表侧表示存在的1只怪兽的守备力直到结束阶段时上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：当前不是伤害步骤，或是伤害步骤但尚未进行伤害计算时才能发动，即限制在伤害步骤的伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c16430187.target)
	e1:SetOperation(c16430187.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择的怪兽条件：表侧表示且守备力在0以上，实质为场上表侧表示存在的怪兽。
function c16430187.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 效果发动时的对象选择处理：先确认指定卡是场上表侧表示怪兽，再检查是否存在至少1只合法对象；若存在则提示玩家选择1只。
function c16430187.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16430187.filter(chkc) end
	-- 效果发动时检查场上是否存在至少1只符合条件的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c16430187.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c16430187.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时，取得对象怪兽；若该怪兽仍与效果关联且表侧表示，则赋予它一个持续到结束阶段、守备力上升700的效果。
function c16430187.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 守备力直到结束阶段时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
