--X－セイバー パシウル
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：对方准备阶段发动。自己受到1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
function c23093604.initial_effect(c)
	-- 效果原文内容：②：对方准备阶段发动。自己受到1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23093604,0))  --"自己受到1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c23093604.condition)
	e1:SetTarget(c23093604.target)
	e1:SetOperation(c23093604.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 条件函数：判断是否满足发动条件，包括卡表侧表示、守备表示且不是当前回合玩家
function c23093604.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前卡必须表侧表示、守备表示且不是当前回合玩家
	return e:GetHandler():IsFaceup() and e:GetHandler():IsDefensePos() and Duel.GetTurnPlayer()~=tp
end
-- 目标设置函数：设置伤害对象和伤害值
function c23093604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为1000点伤害
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为伤害效果，目标玩家为当前玩家，伤害值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 效果处理函数：检查卡是否仍然在场且处于守备表示，然后执行伤害效果
function c23093604.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not e:GetHandler():IsPosition(POS_FACEUP_DEFENSE) then return end
	-- 从连锁信息中获取目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
