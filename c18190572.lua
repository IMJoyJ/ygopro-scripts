--ミクロ光線
-- 效果：
-- 使场上1张表侧表示怪兽的守备力变成零直到结束阶段终了时为止。
function c18190572.initial_effect(c)
	-- 使场上1张表侧表示怪兽的守备力变成零直到结束阶段终了时为止。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果发动条件为aux.dscon，即不在伤害步骤或伤害步骤中尚未进行伤害计算时才能发动（确保只能在伤害计算前发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c18190572.target)
	e1:SetOperation(c18190572.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示且守备力在0以上的怪兽，即选择场上1张表侧表示怪兽。
function c18190572.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 效果发动的目标选择处理：检查是否存在合法对象，并让玩家从场上表侧表示怪兽中选择1张作为对象。
function c18190572.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18190572.filter(chkc) end
	-- 在发动时检查场上是否存在至少1张符合条件的表侧表示怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c18190572.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示提示消息，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只场上表侧表示怪兽作为对象，并将其登记为当前连锁的目标。
	Duel.SelectTarget(tp,c18190572.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果关联且表侧表示，则赋予其守备力变为0直到结束阶段的效果。
function c18190572.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 守备力变成零直到结束阶段终了时为止。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
