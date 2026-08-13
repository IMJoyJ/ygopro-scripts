--セイクリッド・スピカ
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的5星怪兽表侧守备表示特殊召唤。
function c40143123.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的5星怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40143123,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c40143123.sptg)
	e2:SetOperation(c40143123.spop)
	c:RegisterEffect(e2)
	c40143123.star_knight_summon_effect=e2
end
-- 检查候选卡是否为名字带有「星圣」的5星怪兽，且能够以表侧守备表示特殊召唤。
function c40143123.filter(c,e,tp)
	return c:IsSetCard(0x53) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动条件判定：自己主要怪兽区有空位，且手牌存在1只满足filter过滤条件的「星圣」5星怪兽（排除exc指定卡）。
function c40143123.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查自己主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足filter（名字带「星圣」、等级5、可表侧守备特殊召唤）的卡，且数量至少1张。
		and Duel.IsExistingMatchingCard(c40143123.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设定本次效果处理的操作信息：要执行的是特殊召唤，从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若主要怪兽区有空位，则提示玩家选择1张手牌中符合条件的「星圣」5星怪兽，并将其表侧守备表示特殊召唤。
function c40143123.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空位，否则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足filter条件的卡（该卡需可作为效果e的特殊召唤对象）。
	local g=Duel.SelectMatchingCard(tp,c40143123.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
