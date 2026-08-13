--グレンザウルス
-- 效果：
-- 3星怪兽×2
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡1个超量素材取除，给与对方基本分1000分伤害。
function c47506081.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用任意2只3星怪兽叠放作为超量素材（不限制种族/属性）。
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
-- 伤害效果的诱发条件：此卡仍与本次战斗关联（未离场或状态未重置），且被战斗破坏的对方怪兽被送去墓地，并且该怪兽是怪兽卡。
function c47506081.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 发动效果的代价：检查自己能否从这张卡上取除1个超量素材作为代价；可以时实际取除1个超量素材。
function c47506081.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的目标设定：无条件可发动；将对象玩家设为对方，伤害值设为1000，并登记效果处理时将造成1000点伤害的操作信息。
function c47506081.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000，即要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记当前连锁的操作信息：效果处理时会给予对方玩家1000点伤害（伤害分类为CATEGORY_DAMAGE）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理阶段：从连锁信息中取出对象玩家和伤害数值，实际给对方造成伤害。
function c47506081.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和伤害参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
