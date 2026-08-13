--精霊獣 カンナホーク
-- 效果：
-- 自己对「精灵兽 雷鹰」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「灵兽」卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
function c49885567.initial_effect(c)
	c:SetSPSummonOnce(49885567)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「灵兽」卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c49885567.target)
	e1:SetOperation(c49885567.operation)
	c:RegisterEffect(e1)
end
-- 筛选卡组中持有「灵兽」字段且能够被除外的卡。
function c49885567.filter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemove()
end
-- 起动效果的发动检查与操作信息设置：确认卡组存在符合条件的「灵兽」卡，并登记本次将进行的除外操作。
function c49885567.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件合法化检查：卡组中是否存在至少1张满足「灵兽」字段且能够被除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49885567.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果的处理信息为从卡组除外1张卡，供连锁上的其他效果正确检测和响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「灵兽」卡以表侧表示除外，并给该卡注册一个在发动者自己的准备阶段回收的效果。
function c49885567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 在己方卡组中选出1张满足条件的「灵兽」卡（不取对象，于效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c49885567.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		-- 发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
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
-- 回收效果的触发条件：当前回合必须是效果发动者自己的准备阶段。
function c49885567.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为效果发动者tp，即是否为发动者自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 回收效果的处理：用Label记录已经历的自己的准备阶段次数；到达第2次自己的准备阶段时，将被除外的卡加入手卡，否则将计数设为1继续等待。
function c49885567.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetHandler():SetTurnCounter(ct+1)
	if ct==1 then
		-- 将之前被除外的这张卡加入其持有者的手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 让对方确认加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,e:GetHandler())
	else e:SetLabel(1) end
end
