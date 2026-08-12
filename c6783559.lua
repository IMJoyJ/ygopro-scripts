--アリジバク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合发动。双方玩家受到1000伤害。
-- ②：这张卡被战斗·效果破坏送去墓地的场合发动。给与对方1000伤害。
function c6783559.initial_effect(c)
	-- ①：这张卡反转的场合发动。双方玩家受到1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6783559,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCountLimit(1,6783559)
	e1:SetTarget(c6783559.target)
	e1:SetOperation(c6783559.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6783559,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,6783560)
	e2:SetCondition(c6783559.damcon)
	e2:SetTarget(c6783559.damtg)
	e2:SetOperation(c6783559.damop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备（检测并设置伤害操作信息）
function c6783559.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：双方玩家受到1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- ①效果的实际处理（双方玩家同时受到1000点伤害）
function c6783559.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给与自己1000点效果伤害（分步处理）
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	-- 给与对方1000点效果伤害（分步处理）
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 完成分步伤害处理，触发伤害时点
	Duel.RDComplete()
end
-- ②效果的发动条件：这张卡因战斗或效果被破坏并送去墓地
function c6783559.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果的发动准备：设置伤害目标为对方玩家，伤害值为1000，并设置操作信息
function c6783559.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的目标参数（伤害值）设置为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ②效果的实际处理：获取目标玩家和伤害值，并给与伤害
function c6783559.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
