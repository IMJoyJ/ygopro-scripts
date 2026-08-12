--競闘－クロス・ディメンション
-- 效果：
-- ①：以自己场上1只「古代的机械」怪兽为对象才能发动。那只怪兽除外。这个效果除外的怪兽在下次的准备阶段回到场上，那个攻击力直到那个回合的结束时变成原本攻击力的2倍。
-- ②：自己场上的「古代的机械巨人」或者「古代的机械巨人-究极重击」被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c56889.initial_effect(c)
	-- 注册卡片密码，表示这张卡的效果文本中记载了「古代的机械巨人」的卡名。
	aux.AddCodeList(c,83104731)
	-- ①：以自己场上1只「古代的机械」怪兽为对象才能发动。那只怪兽除外。这个效果除外的怪兽在下次的准备阶段回到场上，那个攻击力直到那个回合的结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c56889.target)
	e1:SetOperation(c56889.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「古代的机械巨人」或者「古代的机械巨人-究极重击」被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c56889.reptg)
	e2:SetValue(c56889.repval)
	e2:SetOperation(c56889.repop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、属于「古代的机械」系列且可以被除外的怪兽。
function c56889.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7) and c:IsAbleToRemove()
end
-- 效果①的发动准备与目标选择。
function c56889.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c56889.rmfilter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的「古代的机械」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c56889.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只符合条件的「古代的机械」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c56889.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果包含除外操作，操作对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的处理：将目标怪兽暂时除外，并注册一个在下次准备阶段使其回到场上且攻击力翻倍的延迟效果。
function c56889.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽是否仍适用此效果，并将其暂时除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		-- 这个效果除外的怪兽在下次的准备阶段回到场上，那个攻击力直到那个回合的结束时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		-- 判断当前是否已经是准备阶段（如果是，则需要等到下个回合的准备阶段再返回）。
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			-- 记录当前的回合数，用于后续判断是否已经到了下一个回合。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c56889.retcon)
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		end
		e1:SetOperation(c56889.retop)
		-- 注册全局延迟效果，用于处理怪兽的返回和攻击力翻倍。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：当前回合数不等于记录的发动回合数（确保在下一次准备阶段触发，而不是当前回合的准备阶段）。
function c56889.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合数是否与记录的回合数不同。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 延迟效果的处理：将怪兽返回场上，并使其攻击力直到回合结束时变成原本攻击力的2倍。
function c56889.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 尝试将暂时除外的怪兽返回到场上。
	if Duel.ReturnToField(tc) then
		local atk=tc:GetBaseAttack()
		-- 那个攻击力直到那个回合的结束时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的「古代的机械巨人」或「古代的机械巨人-究极重击」因战斗或效果被破坏。
function c56889.repfilter(c,tp)
	return c:IsFaceup() and c:IsCode(83104731,95735217)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动条件与目标确认：检查墓地的这张卡是否可以除外，以及是否有符合条件的怪兽将被破坏。
function c56889.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c56889.repfilter,1,nil,tp) end
	-- 询问玩家是否使用墓地的这张卡代替破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用对象。
function c56889.repval(e,c)
	return c56889.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理：将墓地的这张卡除外。
function c56889.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
