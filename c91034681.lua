--デストーイ・デアデビル
-- 效果：
-- 「锋利小鬼」怪兽＋「毛绒动物」怪兽
-- 「魔玩具·冒失鬼」的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方1000伤害。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。给与对方为自己墓地的「魔玩具」怪兽数量×500伤害。
function c91034681.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「锋利小鬼」怪兽和「毛绒动物」怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc3),aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),true)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91034681,0))  --"给与对方1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- 设置发动条件为这张卡战斗破坏对方怪兽
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c91034681.damtg1)
	e1:SetOperation(c91034681.damop1)
	c:RegisterEffect(e1)
	-- 「魔玩具·冒失鬼」的②的效果1回合只能使用1次。②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。给与对方为自己墓地的「魔玩具」怪兽数量×500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91034681,1))  --"给与对方「魔玩具」怪兽数量×500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,91034681)
	e2:SetCondition(c91034681.damcon2)
	e2:SetTarget(c91034681.damtg2)
	e2:SetOperation(c91034681.damop2)
	c:RegisterEffect(e2)
end
-- 效果①的靶向与发动检测：设置伤害目标玩家为对方，伤害数值为1000
function c91034681.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的参数值为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为给与对方1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果①的执行：获取目标玩家和伤害数值，并给与对方伤害
function c91034681.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果②的发动条件检测：表侧表示的这张卡被战斗破坏，或者因对方的效果从场上离开
function c91034681.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤自己墓地中的「魔玩具」怪兽
function c91034681.damfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xad)
end
-- 效果②的靶向与发动检测：确认自己墓地有「魔玩具」怪兽，并设置伤害目标玩家为对方，伤害数值为墓地「魔玩具」怪兽数量×500
function c91034681.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己墓地中满足条件的「魔玩具」怪兽数量
	local gc=Duel.GetMatchingGroupCount(c91034681.damfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return gc>0 end
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的操作信息为给与对方「魔玩具」怪兽数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,gc*500)
end
-- 效果②的执行：计算自己墓地的「魔玩具」怪兽数量，获取目标玩家并给与对应的伤害
function c91034681.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算自己墓地中满足条件的「魔玩具」怪兽数量
	local gc=Duel.GetMatchingGroupCount(c91034681.damfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果伤害的方式给与目标玩家「魔玩具」怪兽数量×500的伤害
	Duel.Damage(p,gc*500,REASON_EFFECT)
end
