--カタパルト・タートル
-- 效果：
-- 1回合1次，把自己场上1只怪兽解放才能发动。给与对方基本分解放的怪兽的攻击力一半数值的伤害。
function c95727991.initial_effect(c)
	-- 1回合1次，把自己场上1只怪兽解放才能发动。给与对方基本分解放的怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95727991,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c95727991.cost)
	e1:SetTarget(c95727991.target)
	e1:SetOperation(c95727991.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上攻击力大于0的怪兽
function c95727991.filter(c)
	return c:GetAttack()>0
end
-- 发动代价：检查并选择场上1只怪兽解放，并记录其攻击力一半的数值
function c95727991.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家场上是否存在至少1只满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c95727991.filter,1,nil) end
	-- 让玩家选择场上1只满足条件的可解放怪兽
	local sg=Duel.SelectReleaseGroup(tp,c95727991.filter,1,1,nil)
	e:SetLabel(math.floor(sg:GetFirst():GetAttack()/2))
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 效果的目标处理：设置伤害的玩家对象、伤害数值以及操作信息
function c95727991.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设置为保存在Label中的解放怪兽攻击力一半的数值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁的操作信息，表明此效果会给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果的处理：获取目标玩家和伤害数值，并给与对方伤害
function c95727991.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应数值的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
