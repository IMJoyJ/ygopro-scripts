--ライカン・スロープ
-- 效果：
-- 用「合成魔术」降临。这张卡给与对方基本分战斗伤害时，给与对方基本分自己墓地存在的通常怪兽数量×200的数值的伤害。
function c84385264.initial_effect(c)
	-- 为怪兽注册记载特定卡牌代码「合成魔术」的关联列表
	aux.AddCodeList(c,72446038)
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
-- 判断伤害效果的发动条件，须为当前给与对方玩家造成战斗伤害
function c84385264.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 伤害效果的发动靶向，计算己方墓地通常怪兽数量对应的伤害数值，并注册操作信息
function c84385264.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己墓地存在的通常怪兽数量，并乘以200计算出伤害值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)*200
	-- 设定效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定效果的对象参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的操作空间，获取设定的对象玩家及伤害参数，对其造成对应的效果伤害
function c84385264.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中所指定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理时再次计算自己墓地通常怪兽数量对应的效果伤害值
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)*200
	-- 以效果伤害的形式给与目标玩家对应的生命值伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
