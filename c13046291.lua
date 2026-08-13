--エヴォルド・メガキレラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只爬虫类族怪兽解放，丢弃1张手卡才能发动。从卡组把1只6星以下的恐龙族·炎属性怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只没有超量素材的龙族超量怪兽为对象才能发动。从自己的手卡·墓地选最多2只爬虫类族·恐龙族的怪兽在作为对象的怪兽下面重叠作为超量素材（同名卡最多1张）。
function c13046291.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上1只爬虫类族怪兽解放，丢弃1张手卡才能发动。从卡组把1只6星以下的恐龙族·炎属性怪兽特殊召唤。
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
	-- 设置②效果的发动代价为把墓地中的这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c13046291.mattg)
	e2:SetOperation(c13046291.matop)
	c:RegisterEffect(e2)
end
-- 定义①效果解放代价的筛选函数：可选择爬虫类族怪兽，且该怪兽是自己控制或表侧表示，同时解放后自己场上仍有可用的怪兽区空格。
function c13046291.costfilter(c,tp)
	-- 筛选条件：爬虫类族；是自己控制或是表侧表示；且解放该怪兽后自己场上仍有可用的怪兽区域。
	return c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的代价函数：在发动时检查能否从场上解放1只满足costfilter的怪兽，同时能否从手卡丢弃1张卡。
function c13046291.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，判断场上是否存在至少1只可解放且符合costfilter条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13046291.costfilter,1,nil,tp)
		-- 同时检查自己手卡中是否存在至少1张可以丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从场上选择1只满足costfilter的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c13046291.costfilter,1,1,nil,tp)
	-- 将选择的怪兽作为COST解放。
	Duel.Release(g,REASON_COST)
	-- 以代价和丢弃的理由从手卡丢弃1张手卡。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果特殊召唤对象的筛选：等级6以下、恐龙族、炎属性，且可以被该效果特殊召唤。
function c13046291.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_EVOLTILE,tp,false,false)
end
-- ①效果的发动条件与操作信息：检查卡组中是否存在符合spfilter的怪兽，并设定将进行从卡组的特殊召唤。
function c13046291.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动时检查卡组是否存在至少1只满足spfilter的恐龙族炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c13046291.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明该效果将把玩家卡组中的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若我方怪兽区有空位，则从卡组选择1只符合条件的恐龙族炎属性怪兽正面表示特殊召唤。
function c13046291.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主要怪兽区没有空位，则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选并选择1只满足spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,c13046291.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,SUMMON_VALUE_EVOLTILE,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的对象筛选：表侧表示、龙族、超量怪兽，且没有超量素材。
function c13046291.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
-- 定义可作为超量素材的卡筛选：种族为爬虫类或恐龙，且允许重叠作为超量素材。
function c13046291.matfilter2(c)
	return c:IsRace(RACE_REPTILE+RACE_DINOSAUR) and c:IsCanOverlay()
end
-- ②效果的发动条件与取对象：选择自己场上1只符合条件的龙族超量怪兽为对象，并确认手卡或墓地中存在可作为超量素材的爬虫类/恐龙族怪兽。
function c13046291.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c13046291.matfilter(chkc) end
	-- 检查自己场上是否存在至少1只满足matfilter的怪兽可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c13046291.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己手卡·墓地中是否存在至少1只满足matfilter2的怪兽。
		and Duel.IsExistingMatchingCard(c13046291.matfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只满足条件的龙族超量怪兽作为这张效果的取对象。
	Duel.SelectTarget(tp,c13046291.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：若对象仍与效果相关且未免疫此效果，则从手卡·墓地选择最多2只卡名不同的爬虫类/恐龙族怪兽，重叠到对象怪兽下方作为超量素材。
function c13046291.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的龙族超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 取得自己手卡和墓地中满足matfilter2且不受王家长眠之谷影响的怪兽集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c13046291.matfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and g:GetCount()>0 then
		-- 向玩家显示“请选择要作为超量素材的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从符合条件的怪兽中选择1~2张，且所选卡片卡名各不相同。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		if sg and sg:GetCount()>0 then
			-- 将选择的怪兽作为超量素材在对象怪兽下方重叠。
			Duel.Overlay(tc,sg)
		end
	end
end
