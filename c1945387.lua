--E・HERO ノヴァマスター
-- 效果：
-- 「元素英雄」怪兽＋炎属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡战斗破坏对方怪兽的场合发动。自己从卡组抽1张。
function c1945387.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤条件，要求融合素材必须是「元素英雄」卡组且属性为炎的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_FIRE),true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为融合召唤的限制条件
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1945387,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果触发条件为自身战斗破坏对方怪兽时
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c1945387.drtg)
	e2:SetOperation(c1945387.drop)
	c:RegisterEffect(e2)
end
c1945387.material_setcode=0x8
-- 设置效果的处理目标为自身玩家，抽卡数量为1
function c1945387.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为效果发动者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息为抽卡效果，目标玩家为效果发动者，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 设置效果的处理操作为让目标玩家从卡组抽1张卡
function c1945387.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行让指定玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
