--マジカル・エクスプロージョン
-- 效果：
-- 自己手卡0张的时候才能发动。给与对方基本分自己墓地存在的魔法卡数量×200分数值的伤害。
function c32723153.initial_effect(c)
	-- 效果原文内容：自己手卡0张的时候才能发动。给与对方基本分自己墓地存在的魔法卡数量×200分数值的伤害。
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
-- 效果作用：检查发动时自己手卡是否为0张
function c32723153.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己手卡数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果原文内容：自己手卡0张的时候才能发动。给与对方基本分自己墓地存在的魔法卡数量×200分数值的伤害。
function c32723153.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断墓地是否存在魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL) end
	-- 效果作用：设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 效果作用：计算墓地魔法卡数量并乘以200得到伤害值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)*200
	-- 效果作用：设置连锁对象参数为伤害值
	Duel.SetTargetParam(dam)
	-- 效果作用：设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果原文内容：自己手卡0张的时候才能发动。给与对方基本分自己墓地存在的魔法卡数量×200分数值的伤害。
function c32723153.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：再次计算墓地魔法卡数量并乘以200得到伤害值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)*200
	-- 效果作用：对对象玩家造成指定伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
