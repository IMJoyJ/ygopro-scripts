--スワップリースト
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为连接素材送去墓地的场合才能发动。这张卡为连接素材的连接怪兽的攻击力下降500。那之后，自己从卡组抽1张。
function c30968774.initial_effect(c)
	-- 创建效果，用于处理作为连接素材被送入墓地时的触发效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30968774,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,30968774)
	e1:SetCondition(c30968774.drcon)
	e1:SetTarget(c30968774.drtg)
	e1:SetOperation(c30968774.drop)
	c:RegisterEffect(e1)
	-- 为效果绑定成为素材的卡片与触发效果，确保能正确识别本次召唤的原因怪兽
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 效果条件：卡片在墓地且因连接召唤成为素材
function c30968774.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 效果目标：设置目标为作为素材的连接怪兽，并检查是否可以抽卡
function c30968774.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	-- 判断是否满足抽卡和目标怪兽有效性的条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and rc:IsRelateToEffect(e) end
	-- 设置当前连锁处理的目标卡片为连接怪兽
	Duel.SetTargetCard(rc)
	-- 设置操作信息为抽卡效果，准备处理抽卡动作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：对连接怪兽攻击力下降500，并执行抽卡
function c30968774.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理的目标卡片（即连接怪兽）
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToChain() then
		-- 为连接怪兽添加攻击力下降500的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
	end
	-- 让玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
