--残骸爆破
-- 效果：
-- 当自己墓地里存在30张以上卡的场合这张卡才能发动。给与对方基本分3000分的伤害。
function c21466326.initial_effect(c)
	-- 当自己墓地里存在30张以上卡的场合这张卡才能发动。给与对方基本分3000分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c21466326.condition)
	e1:SetTarget(c21466326.target)
	e1:SetOperation(c21466326.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：必须在自己墓地存在30张以上卡时才能发动。
function c21466326.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己墓地（tp方，LOCATION_GRAVE）的卡数量，判断是否大于等于30张。
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=30
end
-- 效果发动时的处理：登记目标玩家和伤害数值，并设置操作信息供后续伤害处理使用。
function c21466326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设置为3000，即造成的伤害数值。
	Duel.SetTargetParam(3000)
	-- 设置当前连锁的操作信息，声明本效果将造成伤害，对象为对方玩家，伤害值为3000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,3000)
end
-- 效果处理阶段：获取之前登记的对象玩家和伤害数值，并对对方造成效果伤害。
function c21466326.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果对象玩家 p 和伤害数值 d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）的方式对玩家 p 造成 d 点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
