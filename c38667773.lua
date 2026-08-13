--星因士 ベガ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从手卡把「星因士 织女一」以外的1只「星骑士」怪兽特殊召唤。
function c38667773.initial_effect(c)
	-- 对应卡片效果原文：“这个卡名的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从手卡把「星因士 织女一」以外的1只「星骑士」怪兽特殊召唤。”
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
-- 定义特殊召唤对象的过滤条件：该卡必须是「星骑士」怪兽，不能是「星因士 织女一」，且能够被特殊召唤。
function c38667773.filter(c,e,tp)
	return c:IsSetCard(0x9c) and not c:IsCode(38667773) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前的合法性检查：确认自己主要怪兽区有空位，并且手牌中存在满足条件的「星骑士」怪兽，才可以发动效果。
function c38667773.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查自己场上主要怪兽区是否有空位，若没有空位则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足过滤条件的「星骑士」怪兽（不是「星因士 织女一」且可被特殊召唤），以此作为发动前提。
		and Duel.IsExistingMatchingCard(c38667773.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设定操作信息：本次效果将在处理时从手卡把1只怪兽特殊召唤，相关区域为自己手牌，供其他效果（如星尘龙等）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行部分：若主要怪兽区仍无空位则直接终止；否则让玩家从手牌选择1只符合条件的「星骑士」怪兽，并以表侧表示特殊召唤到自己场上。
function c38667773.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若没有空位则效果不处理，避免特殊召唤失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，告知玩家需要从手牌选择要特殊召唤的卡，并设置对应的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选并选择1张满足过滤条件的「星骑士」怪兽作为特殊召唤对象，且该卡不是「星因士 织女一」，同时将选择结果作为当前连锁的对象。
	local g=Duel.SelectMatchingCard(tp,c38667773.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只「星骑士」怪兽以表侧表示特殊召唤到自己场上，不额外检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
