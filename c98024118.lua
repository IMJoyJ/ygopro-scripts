--ホワイトポータン
-- 效果：
-- 自己场上有调整表侧表示存在的场合，这张卡不会被战斗破坏。自己场上表侧表示存在的调整被战斗破坏送去墓地时，给与对方基本分500分伤害。
function c98024118.initial_effect(c)
	-- 自己场上有调整表侧表示存在的场合，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c98024118.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的调整被战斗破坏送去墓地时，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98024118,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c98024118.damcon)
	e2:SetTarget(c98024118.damtg)
	e2:SetOperation(c98024118.damop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的调整怪兽
function c98024118.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 战斗不破效果的启用条件：自己场上存在表侧表示的调整怪兽
function c98024118.indcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的调整怪兽
	return Duel.IsExistingMatchingCard(c98024118.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：原本由自己控制、在场上表侧表示存在、因战斗破坏并送去墓地的调整怪兽
function c98024118.filter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsType(TYPE_TUNER)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 伤害效果的发动条件：被战斗破坏送去墓地的卡中存在满足条件的调整怪兽
function c98024118.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c98024118.filter,1,nil,tp)
end
-- 伤害效果的发动准备（设置效果分类、目标玩家、目标参数及操作信息）
function c98024118.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为500（伤害数值）
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为：给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的处理逻辑
function c98024118.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果对目标玩家造成对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
