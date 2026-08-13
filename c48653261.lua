--ガードペナルティ
-- 效果：
-- 选择场上1只怪兽。这个回合选择的怪兽变成守备表示的场合，从自己卡组抽1张卡。
function c48653261.initial_effect(c)
	-- 选择场上1只怪兽。这个回合选择的怪兽变成守备表示的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48653261.target)
	e1:SetOperation(c48653261.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的取对象处理：检查场上是否存在可选怪兽，并让发动者选择场上1只怪兽作为效果对象。
function c48653261.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 判定阶段：检查场上是否存在至少1只可以作为效果对象的怪兽（取对象效果）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动者发送选择对象的提示信息，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动者从双方场上选择1只怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理阶段：取得对象怪兽，若其仍与效果关联，则为其设置一个持续监视表示变更的辅助效果，该效果在回合结束阶段重置。
function c48653261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象怪兽（最初选择的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合选择的怪兽变成守备表示的场合，从自己卡组抽1张卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHANGE_POS)
		e1:SetCountLimit(1)
		e1:SetCondition(c48653261.drcon)
		e1:SetOperation(c48653261.drop)
		e1:SetLabel(tc:GetRealFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将监视怪兽表示变更的持续效果注册到tp方场上，使其可以在满足条件时发动抽卡。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 筛选条件：判断某张卡是否为之前选择的对象怪兽（通过真实字段ID识别），且当前为守备表示、变更前为攻击表示，即发生了从攻击表示变为守备表示的变化。
function c48653261.filter(c,fid)
	return c:GetRealFieldID()==fid and c:IsDefensePos() and c:IsPreviousPosition(POS_ATTACK)
end
-- 触发条件：事件组中存在满足filter筛选的怪兽，也就是之前选择的那只怪兽从攻击表示变成了守备表示。
function c48653261.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48653261.filter,1,nil,e:GetLabel())
end
-- 效果处理：让卡片发动者抽1张卡，随后重置该辅助效果，确保本回合只抽1次。
function c48653261.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让tp玩家因效果抽1张卡，返回实际抽取数量。
	Duel.Draw(tp,1,REASON_EFFECT)
	e:Reset()
end
