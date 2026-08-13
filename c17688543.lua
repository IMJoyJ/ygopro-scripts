--深すぎた墓穴
-- 效果：
-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。下次的自己准备阶段把那只怪兽从墓地往自己场上特殊召唤。
function c17688543.initial_effect(c)
	-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c17688543.target)
	e1:SetOperation(c17688543.activate)
	c:RegisterEffect(e1)
end
-- 效果的目标判定函数：验证选择对象的合法性，并在发动时检查己方场上有空位且墓地存在可特殊召唤的怪兽。
function c17688543.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsSpecialSummonableCard() end
	-- 发动条件检查：己方主要怪兽区域必须存在空位，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地中存在至少1只可特殊召唤的怪兽，可作为发动效果的对象。
		and Duel.IsExistingTarget(Card.IsSpecialSummonableCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己或对方的墓地选择1只可特殊召唤的怪兽作为效果对象并建立连锁关联。
	local g=Duel.SelectTarget(tp,Card.IsSpecialSummonableCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁处理信息，声明本效果将进行特殊召唤，目标为所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：对象仍然存在时，创建延迟效果，在下次自己准备阶段将其特殊召唤，并处理当前准备阶段发动的边界情况。
function c17688543.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时所选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		-- 下次的自己准备阶段把那只怪兽从墓地往自己场上特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c17688543.spcon)
		e1:SetOperation(c17688543.spop)
		-- 判断当前是否正是自己的准备阶段，以决定延迟效果的重置和触发方式。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 将当前回合数记录到效果值中，作为判断“下次”准备阶段的依据。
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(17688543,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(17688543,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
		end
		-- 将延迟效果注册到场上，使其在后续准备阶段时点接受检查并触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：当前是自己的准备阶段且非效果登记时的准备阶段。
function c17688543.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 通过回合玩家与回合数的比对，确保只在下次自己的准备阶段满足条件。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetValue()
end
-- 延迟效果触发后的处理：核对对象仍有效后将其特殊召唤到自己场上。
function c17688543.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffectLabel(17688543)==e:GetLabel() then
		-- 展示卡片动画，提示玩家正在处理“过深的墓穴”的效果。
		Duel.Hint(HINT_CARD,0,17688543)
		-- 把对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
