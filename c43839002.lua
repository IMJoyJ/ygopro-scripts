--サイバネット・バックドア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只电子界族怪兽为对象才能发动。那只怪兽除外，把持有比那只怪兽的原本攻击力低的攻击力的1只电子界族怪兽从卡组加入手卡。这个效果除外的怪兽在下次的自己准备阶段回到场上，那个回合可以直接攻击。
function c43839002.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只电子界族怪兽为对象才能发动。那只怪兽除外，把持有比那只怪兽的原本攻击力低的攻击力的1只电子界族怪兽从卡组加入手卡。这个效果除外的怪兽在下次的自己准备阶段回到场上，那个回合可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,43839002+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43839002.target)
	e1:SetOperation(c43839002.activate)
	c:RegisterEffect(e1)
end
-- 定义发动时可选对象的过滤条件：对象必须是表侧表示、电子界族、可以被除外、原本攻击力数值大于0、原本是怪兽卡，并且自己卡组中存在攻击力低于该对象原本攻击力的电子界族怪兽，从而确保后续检索不会空发。
function c43839002.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemove() and c:GetTextAttack()>0 and c:GetOriginalType()&TYPE_MONSTER~=0
		-- 追加过滤：检查自己卡组中是否存在至少1只满足thfilter的电子界族怪兽（其当前攻击力低于作为对象的电子界族怪兽的原本攻击力），用于保证对象选择时检索是有意义的。
		and Duel.IsExistingMatchingCard(c43839002.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetTextAttack())
end
-- 定义检索卡组时的过滤条件：卡组中的怪兽必须是电子界族、原本攻击力不是未知（>=0）、当前攻击力低于传入的atk（对象怪兽的原本攻击力），并且能够加入手卡。
function c43839002.thfilter(c,atk)
	return c:IsRace(RACE_CYBERSE) and c:GetTextAttack()>=0 and c:GetAttack()<atk and c:IsAbleToHand()
end
-- 发动时处理：确认有合法对象后，让玩家从自己场上选择1只符合条件的电子界族怪兽作为对象，并设置“除外该对象”和“从卡组加入手卡”的操作信息。
function c43839002.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43839002.rmfilter(chkc,tp) end
	-- 发动合法性判定：若自己场上不存在满足rmfilter条件的电子界族怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43839002.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 在玩家选择对象前，显示“请选择要除外的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动玩家从自己场上选择1只满足rmfilter条件的电子界族怪兽，并自动将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c43839002.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本次连锁会以1张为单位将该对象卡除外，使“除外”相关判定（如星尘龙等）能够正确响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本次连锁会从玩家自己卡组把1张卡加入手卡；由于具体哪张卡在效果处理时才确定，targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取得对象后，若对象仍然与效果关联，则将其以暂时除外的方式除外；成功后创建一个在下次自己准备阶段将其返回场地的持续效果，然后从卡组检索攻击力低于对象原本攻击力的电子界族怪兽加入手卡并给对方确认。
function c43839002.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中记录的效果对象（即发动时选择的那只电子界族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡仍与本次效果有关联（未离场或未被重置联系），并尝试以效果原因、暂时除外的方式将其除外；如果除外成功才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		local fid=c:GetFieldID()
		-- 那只怪兽除外，把持有比那只怪兽的原本攻击力低的攻击力的1只电子界族怪兽从卡组加入手卡。这个效果除外的怪兽在下次的自己准备阶段回到场上，那个回合可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c43839002.retcon)
		e1:SetOperation(c43839002.retop)
		-- 判断效果处理时是否已经处于自己的准备阶段；若是，则需要调整待机效果的复位次数和基准回合数，以避免在当前正在进行的准备阶段就立刻触发返回。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 将当前回合数记录到效果e1的Value中，作为“下次自己准备阶段”的判定基准，防止效果在当前准备阶段被立即触发。
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(43839002,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(43839002,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
		end
		-- 把创建好的准备阶段待机效果e1注册到发动玩家tp，使其持续监测后续准备阶段的到来。
		Duel.RegisterEffect(e1,tp)
		if tc:IsFacedown() then return end
		-- 执行检索前，显示“请选择要加入手牌的卡”的提示文字。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组中选择1张满足thfilter条件的电子界族怪兽（攻击力低于对象原本攻击力、可加入手卡）。
		local g=Duel.SelectMatchingCard(tp,c43839002.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetTextAttack())
		if g:GetCount()>0 then
			-- 将检索到的卡以“效果”的原因加入其持有者的手卡，完成检索。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片，用于确认这次不取对象检索所加入的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 这是“下次自己准备阶段返回”的触发条件函数：只有当前是自己的准备阶段，且不是效果发动时所在的那次准备阶段时，才允许执行返回。
function c43839002.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：当前回合玩家是效果发动者，且当前回合数与e:GetValue()不相等（若Value为0则只要到自己的准备阶段就满足），确保只在“下次”自己的准备阶段触发。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetValue()
end
-- 返回处理：从效果LabelObject中取得被除外的怪兽，若其仍带有与本次效果对应的标记并成功返回场上，则给它赋予这个回合可以直接攻击的效果。
function c43839002.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断被除外的怪兽身上的FlagEffect标记与本次效果记录的fid一致，确认是同一只被暂时除外的怪兽，然后尝试将其返回场上；返回成功才继续赋予直接攻击效果。
	if tc:GetFlagEffectLabel(43839002)==e:GetLabel() and Duel.ReturnToField(tc) then
		-- 那个回合可以直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetDescription(aux.Stringid(43839002,0))  --"「电脑网后门」效果适用中"
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
