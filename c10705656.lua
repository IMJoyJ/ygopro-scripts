--ウィジェット・キッド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只电子界族怪兽守备表示特殊召唤。
function c10705656.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只电子界族怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10705656,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10705656)
	e1:SetTarget(c10705656.sptg)
	e1:SetOperation(c10705656.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 该过滤函数用于筛选手牌中满足“电子界族怪兽”且能被当前效果以表侧守备表示特殊召唤（符合召唤条件及苏生限制）的卡。
function c10705656.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标判定：确认自己场上存在可用的主要怪兽区，且手牌中有满足条件的电子界族怪兽，才能发动。
function c10705656.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1个可用的主要怪兽区空格，确保特殊召唤有格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌中是否存在至少1张能满足电子界族且可特殊召唤条件的怪兽，作为发动的前提。
		and Duel.IsExistingMatchingCard(c10705656.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理将进行特殊召唤，预计从手牌特殊召唤1只怪兽（对象在处理时确定，因此targets设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：若仍有空位，则提示玩家选择要特殊召唤的卡，从手牌选择1只符合filter的电子界族怪兽，以表侧守备表示特殊召唤到自己场上。
function c10705656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有主要怪兽区空格，否则本次处理直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息，用于选择卡片的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选出1张满足filter条件的电子界族怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c10705656.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧守备表示特殊召唤到自己的主要怪兽区，完成特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
