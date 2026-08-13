--ヘル・ブランブル
-- 效果：
-- 调整＋调整以外的植物族怪兽1只以上
-- 只要这张卡在场上表侧表示存在，双方必须为从手卡把植物族怪兽以外的怪兽召唤·特殊召唤支付每1只1000基本分。
function c45500495.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以任意1只调整怪兽＋1只以上调整以外的植物族怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_PLANT),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，双方必须为从手卡把植物族怪兽以外的怪兽召唤·特殊召唤支付每1只1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_COST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(c45500495.sumtg)
	e1:SetCost(c45500495.ccost)
	e1:SetOperation(c45500495.acop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SPSUMMON_COST)
	c:RegisterEffect(e2)
end
-- 召唤代价的判定函数：判断从手卡召唤或特殊召唤的怪兽是否为植物族以外，若是则触发该代价效果。
function c45500495.sumtg(e,c)
	return c:GetRace()~=RACE_PLANT
end
-- 召唤代价的检查函数：确认玩家能否支付1000基本分，作为是否允许进行该召唤·特殊召唤的前提条件。
function c45500495.ccost(e,c,tp)
	-- 检查玩家tp是否能够支付1000基本分，返回布尔值。
	return Duel.CheckLPCost(tp,1000)
end
-- 召唤代价的操作函数：在召唤或特殊召唤实际处理时，执行扣除玩家1000基本分的代价。
function c45500495.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家tp支付1000基本分，实际从生命值中扣除该代价。
	Duel.PayLPCost(tp,1000)
end
