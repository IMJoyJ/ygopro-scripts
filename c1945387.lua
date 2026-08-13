--E・HERO ノヴァマスター
-- 效果：
-- 「元素英雄」怪兽＋炎属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡战斗破坏对方怪兽的场合发动。自己从卡组抽1张。
function c1945387.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材要求为「元素英雄」怪兽和炎属性怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_FIRE),true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤条件的判定函数为aux.fuslimit，只有通过融合召唤方式进行的特殊召唤才被允许。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1945387,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置触发条件为aux.bdocon，即这张卡与对方怪兽战斗并将对方怪兽战斗破坏时条件成立。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c1945387.drtg)
	e2:SetOperation(c1945387.drop)
	c:RegisterEffect(e2)
end
c1945387.material_setcode=0x8
-- 效果发动时的目标处理函数：不取对象且必定发动，返回true；然后设置目标玩家为自己、目标参数为1，并登记抽卡的操作信息。
function c1945387.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为效果发动者tp，即抽卡玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记操作信息：该效果属于抽卡效果（CATEGORY_DRAW），目标玩家为tp，抽卡数为1，供其他效果进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理执行函数：从当前连锁信息中取得目标玩家和抽卡数量，然后执行抽卡，完成抽卡效果。
function c1945387.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中保存的目标玩家p和抽卡数量d，分别赋值给局部变量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因REASON_EFFECT抽d张卡，即自己从卡组抽1张加入手牌。
	Duel.Draw(p,d,REASON_EFFECT)
end
