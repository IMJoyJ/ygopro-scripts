--ヘル・ブランブル
-- 效果：
-- 调整＋调整以外的植物族怪兽1只以上
-- 只要这张卡在场上表侧表示存在，双方必须为从手卡把植物族怪兽以外的怪兽召唤·特殊召唤支付每1只1000基本分。
function c45500495.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的植物族怪兽作为素材
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
-- 设置效果目标为手卡中种族不是植物族的怪兽
function c45500495.sumtg(e,c)
	return c:GetRace()~=RACE_PLANT
end
-- 设置支付代价函数，检查玩家是否能支付1000基本分
function c45500495.ccost(e,c,tp)
	-- 检查玩家是否能支付1000基本分
	return Duel.CheckLPCost(tp,1000)
end
-- 设置效果发动时的处理函数，支付1000基本分
function c45500495.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
