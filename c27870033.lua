--チェイス・スカッド
-- 效果：
-- 场上守备表示存在的怪兽被战斗破坏送去墓地时，给与对方基本分500分伤害。
function c27870033.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27870033,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c27870033.damcon)
	e1:SetTarget(c27870033.damtg)
	e1:SetOperation(c27870033.damop)
	c:RegisterEffect(e1)
end
-- 场上守备表示存在的怪兽被战斗破坏送去墓地时，给与对方基本分500分伤害。
function c27870033.cfilter(c)
	return c:IsPreviousPosition(POS_DEFENSE) and c:IsLocation(LOCATION_GRAVE)
		and c:IsReason(REASON_BATTLE) and c:IsType(TYPE_MONSTER)
end
-- 检索满足条件的卡片组
function c27870033.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27870033.cfilter,1,nil)
end
-- 设置连锁处理的目标玩家和参数
function c27870033.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前正在处理的连锁的对象玩家设置成对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前正在处理的连锁的对象参数设置成500
	Duel.SetTargetParam(500)
	-- 设置当前处理的连锁的操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 处理连锁的伤害效果
function c27870033.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因给与目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
