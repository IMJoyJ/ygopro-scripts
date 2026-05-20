--魔法の国の王女－ピケル
-- 效果：
-- 这张卡不能通常召唤。这张卡只能通过「王女的试炼」的效果才能特殊召唤。自己准备阶段时，回复自己场上存在的怪兽数量×800的数值的基本分。
function c75917088.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。这张卡只能通过「王女的试炼」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己准备阶段时，回复自己场上存在的怪兽数量×800的数值的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75917088,0))  --"LP回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c75917088.condition)
	e2:SetTarget(c75917088.target)
	e2:SetOperation(c75917088.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动的条件函数，判断是否为自己的回合
function c75917088.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动的目标处理函数，计算回复数值并设置目标玩家
function c75917088.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 将当前回合玩家（自己）设定为效果影响的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的操作信息为回复效果，回复数值为自己场上怪兽数量×800
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*800)
end
-- 定义效果的处理函数，执行回复基本分的操作
function c75917088.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取效果处理时自己场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 使目标玩家回复对应数值的基本分
	Duel.Recover(p,ct*800,REASON_EFFECT)
end
