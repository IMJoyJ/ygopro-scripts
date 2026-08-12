--封印の黄金櫃
-- 效果：
-- ①：从卡组选1张卡除外。这张卡的发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
function c75500286.initial_effect(c)
	-- ①：从卡组选1张卡除外。这张卡的发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c75500286.target)
	e1:SetOperation(c75500286.activate)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备与合法性检测
function c75500286.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理为将卡组的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的实际处理，执行除外并注册后续加入手卡的效果
function c75500286.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组选择1张可以除外的卡
	local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local fid=c:GetFieldID()
	-- 若成功将卡片表侧表示除外，且该效果是由魔法卡发动触发
	if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		rc:RegisterFlagEffect(75500286,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
		-- 这张卡的发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e1:SetLabel(fid,0)
		e1:SetLabelObject(rc)
		e1:SetCondition(c75500286.thcon)
		e1:SetOperation(c75500286.thop)
		-- 注册该全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟加入手卡效果的触发条件函数
function c75500286.thcon(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	-- 必须是自己的回合，且目标卡片仍带有对应的标记
	return Duel.GetTurnPlayer()==tp and tc:GetFlagEffectLabel(75500286)==fid
end
-- 延迟加入手卡效果的执行函数，在第2次准备阶段将卡加入手卡
function c75500286.thop(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	local tc=e:GetLabelObject()
	ct=ct+1
	e:GetHandler():SetTurnCounter(ct)
	e:SetLabel(fid,ct)
	if ct~=2 then return end
	if tc:GetFlagEffectLabel(75500286)==fid then
		-- 将除外的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
