--KA－2 デス・シザース
-- 效果：
-- 这张卡战斗破坏怪兽并将其送去墓地时，对对方基本分造成数值等同于被破坏怪兽等级×500点的伤害。
function c52768103.initial_effect(c)
	-- 这张卡战斗破坏怪兽并将其送去墓地时，对对方基本分造成数值等同于被破坏怪兽等级×500点的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52768103,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c52768103.damcon)
	e1:SetTarget(c52768103.damtg)
	e1:SetOperation(c52768103.damop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：此卡仍与本次战斗关联，战斗目标怪兽在墓地且因战斗破坏，并且该怪兽是怪兽卡时满足。
function c52768103.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 效果发动时的目标处理：取得被战斗破坏的怪兽的等级×500作为伤害值，设定对方玩家为伤害对象，并登记伤害效果的操作信息。
function c52768103.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=bc:GetLevel()*500
	-- 将当前连锁的对象玩家设为对方（1-tp），即由对方承受这次伤害。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为计算出的伤害值dam，供效果处理时使用。
	Duel.SetTargetParam(dam)
	-- 登记本次连锁的操作信息：效果分类为伤害（CATEGORY_DAMAGE），目标玩家为对方，伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数：从连锁信息中取出预先设定的对象玩家和伤害值，并给予伤害。
function c52768103.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标玩家p和目标参数d（即先前设置的对象玩家与伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以卡的效果（REASON_EFFECT）给予玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
