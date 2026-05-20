--ライカン・スロープ
-- 效果：
-- 用「合成魔术」降临。这张卡给与对方基本分战斗伤害时，给与对方基本分自己墓地存在的通常怪兽数量×200的数值的伤害。
function c84385264.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡给与对方基本分战斗伤害时，给与对方基本分自己墓地存在的通常怪兽数量×200的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84385264,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c84385264.damcon)
	e1:SetTarget(c84385264.damtg)
	e1:SetOperation(c84385264.damop)
	c:RegisterEffect(e1)
end
-- 判断受到战斗伤害的玩家是否为对方
function c84385264.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标设置，计算伤害数值并指定对方玩家为伤害对象
function c84385264.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己墓地存在的通常怪兽数量乘以200的数值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)*200
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为伤害数值
	Duel.SetTargetParam(dam)
	-- 设置操作信息，表示该效果会给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理的执行，获取目标玩家并给与对应的效果伤害
function c84385264.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算效果处理时自己墓地存在的通常怪兽数量乘以200的数值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)*200
	-- 给与目标玩家计算出的效果伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
