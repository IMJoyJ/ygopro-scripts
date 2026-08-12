--対空放花
-- 效果：
-- 每祭掉自己场上1只昆虫族怪兽，给与对方基本分800分的伤害。
function c65064143.initial_effect(c)
	-- 每祭掉自己场上1只昆虫族怪兽，给与对方基本分800分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65064143,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c65064143.damcost)
	e1:SetTarget(c65064143.damtg)
	e1:SetOperation(c65064143.damop)
	c:RegisterEffect(e1)
end
-- 效果发动代价（Cost）处理函数：解放自己场上的昆虫族怪兽
function c65064143.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在至少1只可解放的昆虫族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_INSECT) end
	-- 选择自己场上1只昆虫族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_INSECT)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果目标（Target）处理函数：设定伤害对象和伤害数值
function c65064143.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为800（伤害数值）
	Duel.SetTargetParam(800)
	-- 设置连锁的操作信息，表示该效果会给与对方玩家800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,800)
end
-- 效果运行（Operation）处理函数：执行伤害计算
function c65064143.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
