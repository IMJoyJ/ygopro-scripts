--ヒロイック・チャンス
-- 效果：
-- 选择自己场上1只名字带有「英豪」的怪兽才能发动。这个回合，选择的怪兽攻击力变成2倍，不能向对方玩家直接攻击。「英豪机会」在1回合只能发动1张。
function c53466826.initial_effect(c)
	-- 选择自己场上1只名字带有「英豪」的怪兽才能发动。「英豪机会」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53466826+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53466826.target)
	e1:SetOperation(c53466826.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是自己场上表侧表示且名字带有「英豪」的怪兽。
function c53466826.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 效果发动前检查是否存在合法对象，并让玩家选择自己场上1只表侧表示且名字带有「英豪」的怪兽作为效果对象。
function c53466826.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53466826.filter(chkc) end
	-- 效果发动合法性检查：确认自己场上是否存在至少1只表侧表示且名字带有「英豪」的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c53466826.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示且名字带有「英豪」的怪兽，并将其登记为本效果的对象。
	Duel.SelectTarget(tp,c53466826.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象，若其仍与效果关联且表侧表示，则赋予其攻击力变为2倍且不能直接攻击的效果，直到回合结束。
function c53466826.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，选择的怪兽攻击力变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不能向对方玩家直接攻击。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
