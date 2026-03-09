--精霊獣 カンナホーク
-- 效果：
-- 自己对「精灵兽 雷鹰」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「灵兽」卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
function c49885567.initial_effect(c)
	c:SetSPSummonOnce(49885567)
	-- 效果原文内容：①：1回合1次，自己主要阶段才能发动。从卡组把1张「灵兽」卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c49885567.target)
	e1:SetOperation(c49885567.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「灵兽」卡（且可以除外）
function c49885567.filter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemove()
end
-- 效果作用：检查是否满足发动条件（卡组存在符合条件的卡）
function c49885567.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件（卡组中是否存在至少1张「灵兽」卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c49885567.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为除外卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择并除外1张「灵兽」卡，并注册一个准备阶段触发的效果
function c49885567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c49885567.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		-- 效果原文内容：发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e1:SetCondition(c49885567.thcon)
		e1:SetOperation(c49885567.thop)
		e1:SetLabel(0)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否为当前回合玩家触发
function c49885567.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：处理准备阶段触发的效果（将除外的卡送入手卡）
function c49885567.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetHandler():SetTurnCounter(ct+1)
	if ct==1 then
		-- 将除外的卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 确认对手看到该卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	else e:SetLabel(1) end
end
