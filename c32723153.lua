--マジカル・エクスプロージョン
-- 效果：
-- 自己手卡0张的时候才能发动。给与对方基本分自己墓地存在的魔法卡数量×200分数值的伤害。
function c32723153.initial_effect(c)
	-- 自己手卡0张的时候才能发动。给与对方基本分自己墓地存在的魔法卡数量×200分数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c32723153.condition)
	e1:SetTarget(c32723153.target)
	e1:SetOperation(c32723153.activate)
	c:RegisterEffect(e1)
end
-- 发动条件的定义：只有自己手牌数为0时，该效果才能发动。
function c32723153.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手牌数量是否为0，即统计自己手牌区域的卡数并判断是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果发动时的目标设定与连锁信息写入：将对方玩家设为效果对象，并计算伤害值存入连锁信息，供处理时使用。
function c32723153.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认自己墓地中至少存在1张魔法卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL) end
	-- 将效果的对象玩家设置为对方玩家，表示该效果以玩家为对象。
	Duel.SetTargetPlayer(1-tp)
	-- 统计自己墓地存在的魔法卡数量，乘以200，得到将要造成的伤害值。
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)*200
	-- 将计算出的伤害值存入当前连锁的对象参数，供效果处理时取得。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：本次连锁的效果分类为伤害，对象玩家为对方，预计伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理时的执行函数：取得连锁中记录的对象玩家，重新计算伤害值，并实际给予伤害。
function c32723153.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前设定的对象玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新统计自己墓地魔法卡数量并乘以200，得到实际造成的伤害值。
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)*200
	-- 以效果原因给对方玩家造成dam点伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
