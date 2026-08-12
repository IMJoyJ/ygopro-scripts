--アロマポット
-- 效果：
-- ①：只要反转过的这张卡在怪兽区域表侧表示存在，这张卡不会被战斗破坏。
-- ②：反转过的这张卡在怪兽区域表侧表示存在的场合，每次双方的结束阶段发动。自己回复500基本分。
function c21452275.initial_effect(c)
	-- ①：只要反转过的这张卡在怪兽区域表侧表示存在，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c21452275.flipop)
	c:RegisterEffect(e1)
	-- ①：只要反转过的这张卡在怪兽区域表侧表示存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c21452275.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：反转过的这张卡在怪兽区域表侧表示存在的场合，每次双方的结束阶段发动。自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c21452275.reccon)
	e3:SetTarget(c21452275.rectg)
	e3:SetOperation(c21452275.recop)
	c:RegisterEffect(e3)
end
-- 记录该卡已反转，用于后续效果条件判断
function c21452275.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(21452275,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判断该卡是否已反转，决定是否生效
function c21452275.indcon(e)
	return e:GetHandler():GetFlagEffect(21452275)~=0
end
-- 判断该卡是否已反转，决定是否发动回复效果
function c21452275.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21452275)~=0
end
-- 设置回复效果的目标玩家和回复数值
function c21452275.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置效果操作信息为回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 执行回复基本分的操作
function c21452275.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
