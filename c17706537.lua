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
	-- 检测是否为与对方怪兽战斗并战斗破坏对方怪兽送去墓地的情况
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c17706537.damtg)
	e1:SetOperation(c17706537.damop)
	c:RegisterEffect(e1)
end
-- 设置伤害效果的目标玩家为对方玩家和伤害值为400
function c17706537.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时伤害效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理时伤害效果的伤害值为400
	Duel.SetTargetParam(400)
	-- 设置连锁操作信息为伤害效果，目标玩家为对方玩家，伤害值为400
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 执行伤害效果，对目标玩家造成指定伤害
function c17706537.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
