--墓荒らしの報い
-- 效果：
-- 每次自己的准备阶段，每存在1只除外的对方怪兽，对方受到100分的伤害。
function c33737664.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,0)
	c:RegisterEffect(e1)
	-- 诱发必发效果，于准备阶段发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33737664,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c33737664.damcon)
	e2:SetTarget(c33737664.damtg)
	e2:SetOperation(c33737664.damop)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断函数
function c33737664.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return tp==Duel.GetTurnPlayer()
end
-- 过滤函数，用于筛选场上正面表示的怪兽
function c33737664.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果发动时的目标设定函数
function c33737664.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果发动时的处理函数
function c33737664.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算除外区对方怪兽数量并乘以100作为伤害值
	local d=Duel.GetMatchingGroupCount(c33737664.filter,tp,0,LOCATION_REMOVED,nil)*100
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
