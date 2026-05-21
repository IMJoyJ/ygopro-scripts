--フレムベル・デビル
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，给与对方基本分自己墓地存在的炎族怪兽数量×200的数值的伤害。
function c91711547.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，给与对方基本分自己墓地存在的炎族怪兽数量×200的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91711547,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c91711547.damcon)
	e1:SetTarget(c91711547.damtg)
	e1:SetOperation(c91711547.damop)
	c:RegisterEffect(e1)
end
-- 判断受到战斗伤害的玩家是否为对方玩家
function c91711547.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标确认与操作信息设置，将对方玩家设为效果对象并声明伤害分类
function c91711547.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息，声明该效果包含给与对方玩家伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理，获取目标玩家并计算自己墓地炎族怪兽数量，给与对应数值的伤害
function c91711547.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家（即受到伤害的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算自己墓地存在的炎族怪兽数量，并乘以200作为伤害数值
	local d=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PYRO)*200
	-- 以效果伤害的形式给与目标玩家计算出的伤害数值
	Duel.Damage(p,d,REASON_EFFECT)
end
