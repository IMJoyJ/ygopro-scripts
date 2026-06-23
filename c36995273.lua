--縮退回路
-- 效果：
-- 只要这张卡在场上存在，从场上回到手卡的怪兽卡不回到手卡从游戏中除外。这张卡的控制者在每次自己的准备阶段支付500基本分。这个时候不能支付500基本分的场合这张卡破坏。
function c36995273.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，从场上回到手卡的怪兽卡不回到手卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_HAND_REDIRECT)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(c36995273.rmtg)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己的准备阶段支付500基本分。这个时候不能支付500基本分的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c36995273.costcon)
	e3:SetOperation(c36995273.costop)
	c:RegisterEffect(e3)
end
-- 目标怪兽为场上怪兽或原本为怪兽卡时才能发动效果
function c36995273.rmtg(e,c)
	return c:IsLocation(LOCATION_MZONE) or bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 判断是否为当前回合玩家的准备阶段
function c36995273.costcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者时才能发动
	return Duel.GetTurnPlayer()==tp
end
-- 支付500基本分或破坏此卡
function c36995273.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否能支付500基本分
	if Duel.CheckLPCost(tp,500) then
		-- 支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 因无法支付费用而破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
