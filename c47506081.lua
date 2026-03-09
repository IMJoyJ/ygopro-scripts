--グレンザウルス
-- 效果：
-- 3星怪兽×2
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡1个超量素材取除，给与对方基本分1000分伤害。
function c47506081.initial_effect(c)
	-- 为卡片添加等级为3、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡1个超量素材取除，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47506081,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c47506081.damcon)
	e1:SetCost(c47506081.damcost)
	e1:SetTarget(c47506081.damtg)
	e1:SetOperation(c47506081.damop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否参与了战斗且战斗破坏的怪兽在墓地且为怪兽类型
function c47506081.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 检查并移除1个超量素材作为发动代价
function c47506081.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置连锁的目标玩家为对方，目标参数为1000点伤害
function c47506081.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息的目标参数为1000点伤害
	Duel.SetTargetParam(1000)
	-- 设置当前处理的连锁的操作信息为伤害效果，影响对方玩家，伤害值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 处理效果时获取目标玩家和伤害值并造成伤害
function c47506081.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
