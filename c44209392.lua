--城壁
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的守备力直到结束阶段时上升500。
function c44209392.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的守备力直到结束阶段时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果在伤害步骤发动的条件限制：仅在伤害步骤且尚未进行伤害计算时允许发动（伤害计算前）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c44209392.target)
	e1:SetOperation(c44209392.activate)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：表侧表示怪兽，且守备力不低于0（即所有表侧表示怪兽）。
function c44209392.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 效果发动时的取对象处理：先确认指定对象在怪兽区且满足筛选条件，再判断是否存在至少1只符合条件的表侧表示怪兽，最后提示玩家选择1只作为对象。
function c44209392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44209392.filter(chkc) end
	-- 发动合法性检查：在当前确认阶段，若场上存在至少1只符合条件的表侧表示怪兽，则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c44209392.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送选择提示消息，提示玩家选择场上表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方怪兽区域选择1只符合条件的表侧表示怪兽，并将其登记为效果的对象。
	Duel.SelectTarget(tp,c44209392.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果关联且表侧表示，则给它赋予守备力上升500的效果，该效果持续到结束阶段。
function c44209392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的守备力直到结束阶段时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
