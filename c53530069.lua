--そよ風の精霊
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，每次自己的准备阶段回复1000基本分。
function c53530069.initial_effect(c)
	-- 创建一个诱发必发效果，当自己的准备阶段开始时发动，满足条件则回复基本分
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53530069,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c53530069.condition)
	e1:SetTarget(c53530069.target)
	e1:SetOperation(c53530069.operation)
	c:RegisterEffect(e1)
end
-- 只要这张卡在自己场上表侧攻击表示存在，每次自己的准备阶段回复1000基本分。
function c53530069.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家且该卡处于表侧攻击表示
	return tp==Duel.GetTurnPlayer() and e:GetHandler():IsAttackPos()
end
-- 设置连锁处理时的目标玩家和参数为1000点基本分
function c53530069.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的目标参数设为1000点基本分
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息，表示本次效果为回复基本分的效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行效果处理，若该卡仍处于表侧攻击表示且与效果相关则进行基本分回复
function c53530069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数（即回复的LP数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 以REASON_EFFECT原因使指定玩家回复对应数值的基本分
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
