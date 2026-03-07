--無差別破壊
-- 效果：
-- 每次自己的准备阶段丢1次骰子。和投出来的数目一样等级的怪兽全部破坏。（投出来的数目是6的场合包括6星以上的怪兽）
function c32015116.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 诱发必发效果，于准备阶段发动，效果原文：每次自己的准备阶段丢1次骰子。和投出来的数目一样等级的怪兽全部破坏。（投出来的数目是6的场合包括6星以上的怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32015116,0))  --"投掷骰子"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c32015116.rdcon)
	e2:SetTarget(c32015116.rdtg)
	e2:SetOperation(c32015116.rdop)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家
function c32015116.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果的发动时点信息，包括骰子效果
function c32015116.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要投掷1个骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 过滤函数，用于筛选满足等级条件的怪兽
function c32015116.rdfilter(c,lv)
	if lv<=5 then
		return c:IsFaceup() and c:IsLevel(lv)
	elseif lv==6 then
		return c:IsFaceup() and c:IsLevelAbove(6)
	else
		return false
	end
end
-- 效果发动时投掷骰子并检索满足条件的怪兽进行破坏
function c32015116.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 投掷1次骰子，结果保存在变量d1中
	local d1=Duel.TossDice(tp,1)
	-- 根据骰子结果筛选场上的怪兽
	local g=Duel.GetMatchingGroup(c32015116.rdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,d1)
	-- 将满足条件的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
