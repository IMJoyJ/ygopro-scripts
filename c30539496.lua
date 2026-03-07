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
-- 过滤函数，返回满足条件的怪兽（在场上或手牌且正面表示）
function c30539496.desfilter(c)
	return c:IsType(TYPE_MONSTER) and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND))
end
-- 过滤函数，返回满足条件的怪兽（在场上且属于该玩家）
function c30539496.locfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c30539496.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft<0 then loc=LOCATION_MZONE end
	local loc2=0
	-- 检查玩家是否受到效果影响，影响可用区域
	if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_MZONE end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c30539496.desfilter,tp,loc,loc2,c)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:GetCount()>=2 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
		and (ft>0 or g:IsExists(c30539496.locfilter,-ft+1,nil,tp)) end
	-- 设置操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,loc)
	-- 设置操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果的发动处理，执行破坏和特殊召唤操作
function c30539496.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_MZONE+LOCATION_HAND
	if ft<0 then loc=LOCATION_MZONE end
	local loc2=0
	-- 检查玩家是否受到效果影响，影响可用区域
	if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc2=LOCATION_MZONE end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c30539496.desfilter,tp,loc,loc2,c)
	if g:GetCount()<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then return end
	local g1=nil local g2=nil
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if ft<1 then
		g1=g:FilterSelect(tp,c30539496.locfilter,1,1,nil,tp)
	else
		g1=g:Select(tp,1,1,nil)
	end
	g:RemoveCard(g1:GetFirst())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	if g1:GetFirst():IsAttribute(ATTRIBUTE_EARTH) then
		g2=g:Select(tp,1,1,nil)
	else
		g2=g:FilterSelect(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_EARTH)
	end
	g1:Merge(g2)
	local rm=g1:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_EARTH)
	-- 破坏满足条件的卡组，若成功则继续处理
	if Duel.Destroy(g1,REASON_EFFECT)==2 then
		if not c:IsRelateToEffect(e) then return end
		-- 将该卡特殊召唤到场上
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end
		-- 获取对方额外卡组中可除外的怪兽组
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		-- 判断是否满足除外额外卡组怪兽的条件
		if rm and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(30539496,2)) then  --"是否把对方的额外卡组的怪兽除外？"
			-- 确认对方额外卡组中的怪兽
			Duel.ConfirmCards(tp,rg)
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 选择最多3种类不同的卡
			local tg=rg:SelectSubGroup(tp,aux.dncheck,false,1,3)
			-- 将选中的卡除外
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
			-- 洗切对方的额外卡组
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- 判断该卡是否因效果被破坏
function c30539496.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，返回满足条件的怪兽（非地属性且为幻龙族）
function c30539496.thfilter(c,e,tp)
	return c:IsNonAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c30539496.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c30539496.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果的发动处理，执行特殊召唤操作
function c30539496.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c30539496.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
