--ナチュル・ビーンズ
-- 效果：
-- 这张卡1回合只有1次不会被战斗破坏。场上表侧表示存在的这张卡被选择作为攻击对象时，给与对方基本分500分伤害。
function c44789585.initial_effect(c)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c44789585.valcon)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被选择作为攻击对象时，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44789585,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetTarget(c44789585.damtg)
	e2:SetOperation(c44789585.damop)
	c:RegisterEffect(e2)
end
-- 返回破坏原因r中是否包含战斗破坏（REASON_BATTLE），用于判定本次破坏是否属于战斗破坏，从而决定是否适用“1回合1次不会被战斗破坏”的替代效果。
function c44789585.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 诱发效果的发动目标处理：在效果发动时（chk==0）无条件允许发动，将对方玩家设为伤害对象、伤害数值设为500，并登记伤害效果的操作信息；效果处理时将实际造成伤害。
function c44789585.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果对象参数设为500，表示这次效果造成的伤害数值为500。
	Duel.SetTargetParam(500)
	-- 登记当前连锁的操作信息：效果分类为伤害（CATEGORY_DAMAGE），对象玩家为对方，预计伤害值为500，供连锁处理及后续判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时的操作函数：取出效果发动时记录的伤害对象玩家和伤害值，并对该玩家造成效果伤害。
function c44789585.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前用SetTargetPlayer和SetTargetParam记录的对象玩家p和对象参数d（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害（若受“伤害变成回复”等影响，实际伤害值由Duel.Damage返回）。
	Duel.Damage(p,d,REASON_EFFECT)
end
