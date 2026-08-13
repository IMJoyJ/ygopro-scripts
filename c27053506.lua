--仕込みマシンガン
-- 效果：
-- ①：给与对方为对方的手卡·场上的卡数量×200伤害。
function c27053506.initial_effect(c)
	-- ①：给与对方为对方的手卡·场上的卡数量×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27053506.target)
	e1:SetOperation(c27053506.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判定与对象/参数设定：在发动时确认对方手牌·场上存在卡片，然后将对方玩家设为对象，计算伤害值并写入连锁操作信息。
function c27053506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：若为合法性检查（chk==0），要求对方手牌·场上至少存在1张卡（0xe为手牌+场上区域），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,0xe,1,nil) end
	-- 将当前连锁的效果对象玩家设为对方（1-tp），表明伤害承受方为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 计算对方手牌与场上的卡总数（Duel.GetFieldGroupCount(1-tp,0xe,0)）乘以200，作为伤害值dam。
	local dam=Duel.GetFieldGroupCount(1-tp,0xe,0)*200
	-- 把计算出的伤害值dam写入连锁的目标参数，效果处理时可读取该参数。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：声明本连锁将进行伤害效果处理，目标为对方（1-tp），预计伤害值为dam，用于发动时点检测与后续互动。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数：从连锁信息中取出对象玩家，重新计算对方手牌·场上的卡数量×200，并给对方造成等量伤害。
function c27053506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果对象玩家p，即先前指定的对方。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算对方手牌与场上的卡总数乘以200，得到实际造成的伤害值dam。
	local dam=Duel.GetFieldGroupCount(1-tp,0xe,0)*200
	-- 以效果原因（REASON_EFFECT）对玩家p造成dam点伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
