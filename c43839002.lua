--サイバネット・バックドア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只电子界族怪兽为对象才能发动。那只怪兽除外，把持有比那只怪兽的原本攻击力低的攻击力的1只电子界族怪兽从卡组加入手卡。这个效果除外的怪兽在下次的自己准备阶段回到场上，那个回合可以直接攻击。
function c43839002.initial_effect(c)
	-- 效果定义：发动时选择自己场上1只电子界族怪兽作为对象，将该怪兽除外，从卡组将攻击力比该怪兽原本攻击力低的1只电子界族怪兽加入手牌。被除外的怪兽在下次自己准备阶段回到场上，该回合可直接攻击。
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
-- 除外怪兽的过滤函数：检查对象是否为表侧表示、电子界族、可除外、原本攻击力大于0、原本类型为怪兽，并且卡组存在攻击力低于该怪兽攻击力的电子界族怪兽。
function c43839002.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemove() and c:GetTextAttack()>0 and c:GetOriginalType()&TYPE_MONSTER~=0
		-- 检查卡组中是否存在攻击力低于目标怪兽攻击力的电子界族怪兽。
		and Duel.IsExistingMatchingCard(c43839002.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetTextAttack())
end
-- 检索怪兽的过滤函数：检查对象是否为电子界族、攻击力大于等于0、攻击力低于指定值、可加入手牌。
function c43839002.thfilter(c,atk)
	return c:IsRace(RACE_CYBERSE) and c:GetTextAttack()>=0 and c:GetAttack()<atk and c:IsAbleToHand()
end
-- 效果处理时的处理函数：选择目标怪兽并设置操作信息。
function c43839002.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43839002.rmfilter(chkc,tp) end
	-- 检查是否满足发动条件：场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c43839002.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽。
	local g=Duel.SelectTarget(tp,c43839002.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：将目标怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动处理函数：将目标怪兽除外并设置返回效果，然后检索卡组。
function c43839002.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效，并将目标怪兽除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		local fid=c:GetFieldID()
		-- 创建一个在下次准备阶段触发的效果，用于将怪兽返回场上并设置直接攻击效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c43839002.retcon)
		e1:SetOperation(c43839002.retop)
		-- 判断是否为当前回合玩家且处于准备阶段。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 记录当前回合数用于条件判断。
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(43839002,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(43839002,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
		end
		-- 将效果注册到玩家环境中。
		Duel.RegisterEffect(e1,tp)
		if tc:IsFacedown() then return end
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的卡加入手牌。
		local g=Duel.SelectMatchingCard(tp,c43839002.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetTextAttack())
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 返回效果的触发条件函数：判断是否为当前回合玩家且回合数不等于记录值。
function c43839002.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家且回合数不等于记录值。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetValue()
end
-- 返回效果的处理函数：将怪兽返回场上并设置直接攻击效果。
function c43839002.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否满足返回条件：怪兽的标志效果标签与效果标签一致且能返回场上。
	if tc:GetFlagEffectLabel(43839002)==e:GetLabel() and Duel.ReturnToField(tc) then
		-- 设置怪兽获得直接攻击效果。
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
