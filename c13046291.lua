--エヴォルド・メガキレラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只爬虫类族怪兽解放，丢弃1张手卡才能发动。从卡组把1只6星以下的恐龙族·炎属性怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只没有超量素材的龙族超量怪兽为对象才能发动。从自己的手卡·墓地选最多2只爬虫类族·恐龙族的怪兽在作为对象的怪兽下面重叠作为超量素材（同名卡最多1张）。
function c13046291.initial_effect(c)
	-- ①：把自己场上1只爬虫类族怪兽解放，丢弃1张手卡才能发动。从卡组把1只6星以下的恐龙族·炎属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13046291,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,13046291)
	e1:SetCost(c13046291.spcost)
	e1:SetTarget(c13046291.sptg)
	e1:SetOperation(c13046291.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只没有超量素材的龙族超量怪兽为对象才能发动。从自己的手卡·墓地选最多2只爬虫类族·恐龙族的怪兽在作为对象的怪兽下面重叠作为超量素材（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13046291,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,13046292)
	-- 将墓地的这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c13046291.mattg)
	e2:SetOperation(c13046291.matop)
	c:RegisterEffect(e2)
end
-- 检查场上是否满足解放条件的爬虫类族怪兽
function c13046291.costfilter(c,tp)
	-- 满足条件的怪兽必须是爬虫类族、控制者是自己或表侧表示，并且场上存在可用的怪兽区域
	return c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- 处理①效果的费用选择函数
function c13046291.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放和丢弃手卡的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13046291.costfilter,1,nil,tp)
		-- 检查手牌中是否存在可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c13046291.costfilter,1,1,nil,tp)
	-- 将选中的怪兽从场上解放
	Duel.Release(g,REASON_COST)
	-- 丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选满足条件的恐龙族·炎属性怪兽
function c13046291.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_EVOLTILE,tp,false,false)
end
-- 处理①效果的发动时选择函数
function c13046291.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13046291.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的发动时处理函数
function c13046291.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c13046291.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,SUMMON_VALUE_EVOLTILE,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选满足条件的龙族超量怪兽
function c13046291.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
-- 筛选满足条件的爬虫类族·恐龙族怪兽
function c13046291.matfilter2(c)
	return c:IsRace(RACE_REPTILE+RACE_DINOSAUR) and c:IsCanOverlay()
end
-- 处理②效果的发动时选择函数
function c13046291.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c13046291.matfilter(chkc) end
	-- 检查场上是否存在满足条件的龙族超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c13046291.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查手牌或墓地中是否存在满足条件的爬虫类族·恐龙族怪兽
		and Duel.IsExistingMatchingCard(c13046291.matfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为对象的龙族超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择1只满足条件的龙族超量怪兽作为对象
	Duel.SelectTarget(tp,c13046291.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理②效果的发动时处理函数
function c13046291.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取手牌和墓地中满足条件的爬虫类族·恐龙族怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c13046291.matfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and g:GetCount()>0 then
		-- 提示玩家选择要叠放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		-- 选择最多2张满足条件且卡名不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		if sg and sg:GetCount()>0 then
			-- 将选中的怪兽叠放至目标怪兽下方
			Duel.Overlay(tc,sg)
		end
	end
end
