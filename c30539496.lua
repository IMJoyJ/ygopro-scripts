--真竜皇リトスアジムD
-- 效果：
-- 「真龙皇 利托斯阿齐姆·灾祸」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从这张卡以外的手卡以及自己场上的表侧表示怪兽之中把包含地属性怪兽的2只怪兽破坏，这张卡从手卡特殊召唤，把2只地属性怪兽破坏的场合，可以把对方的额外卡组确认并从那之中选怪兽最多3种类除外。
-- ②：这张卡被效果破坏的场合才能发动。从自己墓地选1只地属性以外的幻龙族怪兽特殊召唤。
function c30539496.initial_effect(c)
	-- ①：自己主要阶段才能发动。从这张卡以外的手卡以及自己场上的表侧表示怪兽之中把包含地属性怪兽的2只怪兽破坏，这张卡从手卡特殊召唤，把2只地属性怪兽破坏的场合，可以把对方的额外卡组确认并从那之中选怪兽最多3种类除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30539496,0))  --"地属性怪兽破坏，这张卡特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30539496)
	e1:SetTarget(c30539496.sptg)
	e1:SetOperation(c30539496.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合才能发动。从自己墓地选1只地属性以外的幻龙族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30539496,1))  --"幻龙族怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,30539497)
	e2:SetCondition(c30539496.spcon2)
	e2:SetTarget(c30539496.sptg2)
	e2:SetOperation(c30539496.spop2)
	c:RegisterEffect(e2)
end
-- 判断一张卡是否符合作为破坏对象的基本条件：是怪兽，且位于手牌，或位于主要怪兽区并表侧表示。
function c30539496.desfilter(c)
	return c:IsType(TYPE_MONSTER) and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND))
end
-- 筛选自己场上的怪兽，用于在特殊召唤区域不足时必须选择至少1只自己场上的怪兽作为破坏对象，以腾出区域。
function c30539496.locfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ①效果的发动条件检测：确认这张卡可以从手牌特殊召唤；候选破坏对象不少于2只且其中至少有1只地属性；若可用区域不足，则还必须存在足够数量的自己场上怪兽以供选择，确保破坏后能腾出特殊召唤区域。
function c30539496.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上当前可用的主要怪兽区域数量（空格数）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft<0 then loc=LOCATION_MZONE end
	local loc2=0
	-- 若自己场上有「真龙皇 法·王·兽」，则其效果允许手卡「真龙」怪兽的破坏效果选择对方场上的怪兽，因此将检索范围扩展到对方场上（loc2设为对方主要怪兽区）。
	if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_MZONE end
	-- 获取所有满足破坏条件的候选怪兽（自己手牌或自己场上的表侧怪兽；若法王兽在场也包含对方场上的表侧怪兽），并排除这张卡自身。
	local g=Duel.GetMatchingGroup(c30539496.desfilter,tp,loc,loc2,c)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:GetCount()>=2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
		and (ft>0 or g:IsExists(c30539496.locfilter,-ft+1,nil,tp)) end
	-- 设置操作信息：宣告本效果将破坏2张卡，对象所在位置为手牌/场上（具体对象在处理时选择），用于连锁检测和效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,loc)
	-- 设置操作信息：宣告本效果将特殊召唤这张卡（自身）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：从候选中选择2只怪兽（其中至少1只为地属性）并破坏；若2只均被成功破坏，则从手牌特殊召唤这张卡；若破坏的2只怪兽均为地属性，则可确认对方额外卡组并从其中选择最多3种类怪兽除外。
function c30539496.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次获取自己场上可用的主要怪兽区域数量，用于确定选择破坏对象的策略（区域不足时必须选择场上怪兽）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft<0 then loc=LOCATION_MZONE end
	local loc2=0
	-- 效果处理时同样检查自己场上是否有「真龙皇 法·王·兽」，以决定是否将对方场上的表侧怪兽纳入破坏候选。
	if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_MZONE end
	-- 效果处理时重新获取候选破坏对象集合（排除自身，若法王兽在场则包含对方场上怪兽）。
	local g=Duel.GetMatchingGroup(c30539496.desfilter,tp,loc,loc2,c)
	if g:GetCount()<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then return end
	local g1=nil local g2=nil
	-- 弹出选择提示：请选择要破坏的卡（第一次选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if ft<1 then
		g1=g:FilterSelect(tp,c30539496.locfilter,1,1,nil,tp)
	else
		g1=g:Select(tp,1,1,nil)
	end
	g:RemoveCard(g1:GetFirst())
	-- 弹出选择提示：请选择要破坏的卡（第二次选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if g1:GetFirst():IsAttribute(ATTRIBUTE_EARTH) then
		g2=g:Select(tp,1,1,nil)
	else
		g2=g:FilterSelect(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_EARTH)
	end
	g1:Merge(g2)
	local rm=g1:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_EARTH)
	-- 通过效果破坏选中的2张卡；若2张卡均被成功破坏，则继续执行后续特殊召唤和额外除外效果。
	if Duel.Destroy(g1,REASON_EFFECT)==2 then
		if not c:IsRelateToEffect(e) then return end
		-- 从手牌以表侧表示特殊召唤这张卡；若召唤失败（数量为0）则不再处理后续的额外除外。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end
		-- 获取对方额外卡组中所有能被除外的卡（用于后续选择除外对象）。
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		-- 若本次破坏的2只怪兽均为地属性，且对方额外卡组存在可除外的卡，则询问玩家是否确认对方额外卡组并除外其中的怪兽。
		if rm and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(30539496,2)) then  --"是否把对方的额外卡组的怪兽除外？"
			-- 向己方玩家展示对方额外卡组的全部卡（确认额外卡组）。
			Duel.ConfirmCards(tp,rg)
			-- 弹出选择提示：请选择要除外的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 从对方额外卡组中选择1至3张卡名互不相同的怪兽卡（最多3种类），作为除外对象。
			local tg=rg:SelectSubGroup(tp,aux.dncheck,false,1,3)
			-- 将选中的怪兽卡以表侧表示除外。
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
			-- 洗切对方的额外卡组。
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- ②效果的发动条件：本卡是受到效果影响而被破坏的（不是战斗破坏），满足“被效果破坏”的要求。
function c30539496.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选②效果可特殊召唤的墓地怪兽：地属性以外的幻龙族怪兽，且能够被特殊召唤。
function c30539496.thfilter(c,e,tp)
	return c:IsNonAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动的合法性检测：自己场上有可用主要怪兽区域，且墓地存在至少1只符合条件的幻龙族怪兽。
function c30539496.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域（必须有空位才能特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足条件的幻龙族怪兽（地属性以外且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c30539496.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：宣告本效果将从墓地特殊召唤1只怪兽，用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从自己墓地选择1只符合条件的幻龙族怪兽，以表侧表示特殊召唤到自己的主要怪兽区域。
function c30539496.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用主要怪兽区域，则终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合条件的幻龙族怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c30539496.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
