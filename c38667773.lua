--星因士 ベガ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从手卡把「星因士 织女一」以外的1只「星骑士」怪兽特殊召唤。
function c38667773.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从手卡把「星因士 织女一」以外的1只「星骑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38667773,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38667773)
	e1:SetTarget(c38667773.sptg)
	e1:SetOperation(c38667773.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c38667773.star_knight_summon_effect=e1
end
-- 检索满足条件的「星骑士」怪兽（排除织女一），并判断是否可以特殊召唤
function c38667773.filter(c,e,tp)
	return c:IsSetCard(0x9c) and not c:IsCode(38667773) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且手牌中有符合条件的怪兽
function c38667773.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c38667773.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置连锁操作信息：将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：检查场上空位并选择手牌中的怪兽进行特殊召唤
function c38667773.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c38667773.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
