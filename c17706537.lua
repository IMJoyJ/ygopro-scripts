--マンモ・フォッシル
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，给与对方基本分400分伤害。
function c17706537.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，给与对方基本分400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17706537,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	-- 设置诱发条件为：此卡与对方怪兽战斗并战斗破坏对方怪兽送去墓地时触发效果。
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c17706537.damtg)
	e1:SetOperation(c17706537.damop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：效果不需要取对象，登记对方玩家为对象玩家、伤害数值为400，并设置操作信息。
function c17706537.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为400，即伤害数值。
	Duel.SetTargetParam(400)
	-- 设置操作信息：本次连锁将造成类别为伤害的效果，目标为对方玩家，伤害值为400。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 效果处理时的操作：从连锁信息中取出对象玩家和伤害数值，执行伤害处理。
function c17706537.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家和对象参数（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因给对象玩家造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
