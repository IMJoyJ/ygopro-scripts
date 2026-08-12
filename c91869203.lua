--アマゾネスの射手
-- 效果：
-- ①：把自己场上2只怪兽解放才能发动。给与对方1200伤害。
function c91869203.initial_effect(c)
	-- ①：把自己场上2只怪兽解放才能发动。给与对方1200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91869203,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c91869203.cost)
	e1:SetTarget(c91869203.target)
	e1:SetOperation(c91869203.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：解放自己场上的2只怪兽
function c91869203.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否存在至少2只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 让发动玩家选择自己场上2只可解放的怪兽
	local sg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 效果的目标设定与操作信息注册
function c91869203.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为1200
	Duel.SetTargetParam(1200)
	-- 设置操作信息为给与对方1200点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- 效果处理：给与对方伤害
function c91869203.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
