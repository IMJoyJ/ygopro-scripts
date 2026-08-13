--タイムカプセル
-- 效果：
-- 从自己卡组选择1张卡，里侧表示从游戏中除外。发动后第2次的自己的准备阶段这张卡破坏，那张卡加入手卡。
function c11961740.initial_effect(c)
	-- 从自己卡组选择1张卡，里侧表示从游戏中除外。发动后第2次的自己的准备阶段这张卡破坏，那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11961740.target)
	e1:SetOperation(c11961740.activate)
	c:RegisterEffect(e1)
end
-- 发动效果的发动条件与操作信息设置函数：检查自己卡组是否有可里侧除外的卡，并登记本次处理将涉及除外的信息。
function c11961740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己卡组存在至少1张可以里侧表示从游戏中除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil,tp,POS_FACEDOWN) end
	-- 设置本次效果的处理信息：效果分类为除外，从自己卡组除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从自己卡组选择1张卡里侧除外，并为自身和被除外的卡设置第二次准备阶段时回收的处理机制。
function c11961740.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		-- 向操作者发出选择提示，提示选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己卡组筛选并选择1张可以里侧除外的卡，取得选择的卡。
		local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil,tp,POS_FACEDOWN):GetFirst()
		-- 若成功选择了卡且该卡被里侧除外，且此效果仍是以魔法卡发动效果处理中，则继续执行后续设置。
		if rc and Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)~=0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			rc:RegisterFlagEffect(11961740,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
			c:CancelToGrave()
			-- 发动后第2次的自己的准备阶段这张卡破坏，那张卡加入手卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetRange(LOCATION_SZONE)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			e1:SetCondition(c11961740.thcon)
			e1:SetOperation(c11961740.thop)
			e1:SetLabel(fid,0)
			e1:SetLabelObject(rc)
			c:RegisterEffect(e1)
		end
	end
end
-- 延迟效果的发动条件函数：仅在满足条件时触发。
function c11961740.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为当前回合玩家是自己，即自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 处理函数：每到自己准备阶段将计数器加1，当计数器到达2时破坏此卡并将除外的卡加入手卡。
function c11961740.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid,ct=e:GetLabel()
	local tc=e:GetLabelObject()
	ct=ct+1
	c:SetTurnCounter(ct)
	e:SetLabel(fid,ct)
	if ct~=2 then return end
	-- 若此卡被效果破坏，且被除外的卡仍带有本次效果登记的时间标识，则执行加入手卡。
	if Duel.Destroy(c,REASON_EFFECT)>0 and tc:GetFlagEffectLabel(11961740)==fid then
		-- 将被里侧除外的卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
