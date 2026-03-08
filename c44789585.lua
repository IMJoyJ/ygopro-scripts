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
-- 判断伤害是否由战斗造成
function c44789585.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 设置伤害效果的目标玩家和伤害值
function c44789585.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理时伤害效果的伤害值为500
	Duel.SetTargetParam(500)
	-- 设置连锁的操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行伤害效果的处理函数
function c44789585.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
