--クリムゾン・ブレーダー／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。把1张「爆裂模式」或者有那个卡名记述的卡从卡组加入手卡，这张卡回到卡组。
-- ②：对方不能把从额外卡组特殊召唤的5星以上的怪兽的效果发动。
-- ③：这张卡被破坏的场合才能发动。从自己墓地把1只「深红剑士」特殊召唤。
local s,id,o=GetID()
-- 注册此卡的全部效果：e0为只能用「爆裂模式」的效果特殊召唤的召唤条件；e1为手牌展示自身检索「爆裂模式/记述其卡名的卡」并回卡组的起动效果（1回合1次）；e2为封锁对方额外卡组特召的5星以上怪兽效果发动的永续效果；e3为被破坏时从墓地特殊召唤「深红剑士」的诱发效果。
function s.initial_effect(c)
	-- 将「爆裂模式」（80280737）和「深红剑士」（80321197）登记到此卡的记述卡名列表中，用于相关卡名检索与判定。
	aux.AddCodeList(c,80280737,80321197)
	-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的具体判定函数为爆裂体通用限制：仅允许通过《爆裂模式》的效果或以爆裂模式方式进行的特殊召唤。
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：把手卡的这张卡给对方观看才能发动。把1张「爆裂模式」或者有那个卡名记述的卡从卡组加入手卡，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方不能把从额外卡组特殊召唤的5星以上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地把1只「深红剑士」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.assault_name=80321197
-- ①的代价判定：此卡必须处于手牌且未公开，以便满足“把手卡的这张卡给对方观看”的发动条件。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤器：候选卡须是「爆裂模式」本身，或是卡面记述了「爆裂模式」的卡，且能够加入手卡。
function s.thfilter(c)
	-- 判断c是否为「爆裂模式」或记述有「爆裂模式」的卡，并且该卡能够被加入手牌。
	return aux.IsCodeOrListed(c,80280737) and c:IsAbleToHand()
end
-- ①的发动条件判定：卡组存在至少1张符合条件的检索对象，且这张发动效果的手牌自身能够返回卡组；同时登记从卡组将1张卡加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时点检查：卡组中存在1张以上满足s.thfilter的检索卡，且当前手牌中的这张卡可以回卡组，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck() end
	-- 向系统登记操作信息：本连锁效果处理时将从卡组把1张卡加入手牌（对象在处理时选择，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：从卡组选择1张「爆裂模式」或记述其卡名的卡加入手牌并向对方展示；若发动效果的此卡仍与连锁相关，则将其弹回持有者卡组并洗牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己的卡组中选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的检索卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的检索卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将发动效果的“深红剑士/爆裂体”这张手牌返回持有者卡组，并洗切卡组。
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- ②的封锁判定：若对方发动的效果是怪兽效果，且效果怪兽等级为5以上、位于怪兽区、并且是从额外卡组特殊召唤而来，则禁止该效果发动。
function s.aclimit(e,re)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLevelAbove(5) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_EXTRA)
end
-- ③的发动条件判定：己方主要怪兽区有空位，且墓地存在可特殊召唤的「深红剑士」；同时登记从墓地特殊召唤1只怪兽的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：己方主要怪兽区空位数大于0，且墓地存在满足s.spfilter的「深红剑士」。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本连锁效果处理时将从墓地特殊召唤1只怪兽（对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤过滤器：目标必须是「深红剑士」（80321197），并且能够被该效果正常特殊召唤（检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsCode(80321197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的效果处理：若己方主要怪兽区仍有空位，则从墓地选择1只不受王家长眠之谷影响的「深红剑士」特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区是否有空位；若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1张既满足“深红剑士且可特殊召唤”，又不受王家长眠之谷效果影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「深红剑士」以表侧表示形式特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
