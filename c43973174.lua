--ドラゴンを呼ぶ笛
-- 效果：
-- ①：从手卡把最多2只龙族怪兽特殊召唤。这个效果在场上有「龙之支配者」存在的场合才能发动和处理。
function c43973174.initial_effect(c)
	-- ①：从手卡把最多2只龙族怪兽特殊召唤。这个效果在场上有「龙之支配者」存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43973174.target)
	e1:SetOperation(c43973174.activate)
	c:RegisterEffect(e1)
end
-- 检查卡片是否为表侧表示且卡号为17985575（龙之支配者），用于确认场上是否存在「龙之支配者」。
function c43973174.cfilter(c)
	return c:IsFaceup() and c:IsCode(17985575)
end
-- 检查手牌中的卡是否为龙族怪兽，且能够被当前效果特殊召唤（符合特殊召唤条件、不受到苏生限制等）。
function c43973174.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：需要自己场上有可用怪兽区、场上存在表侧表示的「龙之支配者」，且手牌中存在至少1只可特殊召唤的龙族怪兽。
function c43973174.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查tp玩家自己主要怪兽区是否存在可用空格，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场上是否存在表侧表示的「龙之支配者」（卡号17985575），用于满足“有龙之支配者存在才能发动”的条件。
		and Duel.IsExistingMatchingCard(c43973174.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查tp玩家手牌中是否存在至少1只满足特殊召唤条件的龙族怪兽，作为效果可发动的必要条件。
		and Duel.IsExistingMatchingCard(c43973174.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果属于特殊召唤，预计从手牌特殊召唤1只怪兽，用于后续发动判定和连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时实际进行特殊召唤：计算可召唤数量（最多2只，若青眼精灵龙效果适用则只能1只），再次确认场上存在龙之支配者，选择手牌中的龙族怪兽并特殊召唤。
function c43973174.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取tp玩家主要怪兽区的可用空格数量，用于决定最多能特殊召唤几只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果处理时再次检查场上是否存在表侧表示的「龙之支配者」，若不存在则效果不处理，符合“才能发动和处理”的规则要求。
	if not Duel.IsExistingMatchingCard(c43973174.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	-- 向tp玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp玩家从手牌中选择1到ft张满足filter条件的龙族怪兽，其中ft为可特殊召唤的数量上限。
	local g=Duel.SelectMatchingCard(tp,c43973174.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的龙族怪兽以表侧表示特殊召唤到tp玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
