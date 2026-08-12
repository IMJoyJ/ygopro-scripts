--タイムカプセル
-- 效果：
-- 从自己卡组选择1张卡，里侧表示从游戏中除外。发动后第2次的自己的准备阶段这张卡破坏，那张卡加入手卡。
function c11961740.initial_effect(c)
	-- 创建效果，设置为魔陷发动，自由连锁，指定目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11961740.target)
	e1:SetOperation(c11961740.activate)
	c:RegisterEffect(e1)
end
-- 效果处理函数的定义
function c11961740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：自己卡组是否存在至少1张可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil,tp,POS_FACEDOWN) end
	-- 设置连锁操作信息，表示将要除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数的定义
function c11961740.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		-- 从自己卡组选择1张卡，里侧表示除外
		local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil,tp,POS_FACEDOWN):GetFirst()
		-- 确认选择的卡被成功除外且效果为发动类型时，注册持续效果
		if rc and Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)~=0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			rc:RegisterFlagEffect(11961740,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
			c:CancelToGrave()
			-- 创建一个持续效果，用于在准备阶段触发
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
-- 准备阶段触发条件函数的定义
function c11961740.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段触发效果处理函数的定义
function c11961740.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid,ct=e:GetLabel()
	local tc=e:GetLabelObject()
	ct=ct+1
	c:SetTurnCounter(ct)
	e:SetLabel(fid,ct)
	if ct~=2 then return end
	-- 判断该卡被破坏且目标卡的标记与当前场ID一致时，将目标卡加入手卡
	if Duel.Destroy(c,REASON_EFFECT)>0 and tc:GetFlagEffectLabel(11961740)==fid then
		-- 将目标卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
