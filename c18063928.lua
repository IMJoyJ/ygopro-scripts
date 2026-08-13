--ブリキンギョ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星怪兽特殊召唤。
function c18063928.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18063928,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c18063928.sptg)
	e1:SetOperation(c18063928.spop)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤的卡片筛选条件：必须是4星怪兽，且能被当前效果以表侧表示特殊召唤（不检查苏生限制）。
function c18063928.filter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标检测：在发动时确认自己场上怪兽区有空位，且手牌中存在满足条件的4星怪兽。
function c18063928.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足c18063928.filter条件的4星怪兽（不取对象，处理时选择）。
		and Duel.IsExistingMatchingCard(c18063928.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果类别为特殊召唤，预计从手牌特殊召唤1只怪兽，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时的操作：若场上仍无怪兽区空位则直接结束；否则让玩家选择手牌中1只符合条件的4星怪兽并特殊召唤。
function c18063928.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有怪兽区空位，若没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足c18063928.filter条件的4星怪兽（不取对象，仅在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c18063928.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
