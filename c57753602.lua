--ジェムフラッシュエナジー
-- 效果：
-- 每次自己的准备阶段给与对方基本分场上表侧表示存在的永续魔法卡数量×300的数值的伤害。
function c57753602.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 每次自己的准备阶段给与对方基本分场上表侧表示存在的永续魔法卡数量×300的数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57753602,0))  --"给与对方伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c57753602.damcon)
	e2:SetTarget(c57753602.damtg)
	e2:SetOperation(c57753602.damop)
	c:RegisterEffect(e2)
end
-- 定义伤害效果的发动条件函数
function c57753602.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合
	return tp==Duel.GetTurnPlayer()
end
-- 过滤函数：筛选场上表侧表示存在的永续魔法卡
function c57753602.filter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x20002)==0x20002
end
-- 定义伤害效果的发动目标（Target）函数
function c57753602.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 定义伤害效果的实际处理（Operation）函数
function c57753602.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算双方魔陷区表侧表示的永续魔法卡数量并乘以300作为伤害值
	local d=Duel.GetMatchingGroupCount(c57753602.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)*300
	-- 因效果给与目标玩家计算出的数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
