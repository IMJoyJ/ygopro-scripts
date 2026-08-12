--真実の眼
-- 效果：
-- 只要这张卡在场上存在，对方把手卡持续公开。对方的准备阶段时对方手卡有魔法卡的场合，对方回复1000基本分。
function c34694160.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方把手卡持续公开
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e2)
	-- 对方的准备阶段时对方手卡有魔法卡的场合，对方回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34694160,0))  --"回复"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c34694160.reccon)
	e3:SetTarget(c34694160.rectg)
	e3:SetOperation(c34694160.recop)
	c:RegisterEffect(e3)
end
-- 判断是否为对方的准备阶段且对方手卡存在魔法卡
function c34694160.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方为非当前回合玩家且对方手卡存在魔法卡
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_HAND,1,nil,TYPE_SPELL)
end
-- 设置回复效果的目标玩家和参数
function c34694160.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为回复效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 执行回复效果
function c34694160.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
