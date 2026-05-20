--溟界妃－アミュネシア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
-- ②：从对方墓地有怪兽特殊召唤的场合才能发动。选对方场上1张卡送去墓地。
-- ③：从对方的手卡·卡组有怪兽被送去墓地的场合才能发动。从自己墓地选「溟界妃-阿蒙涅西娅」以外的1只光·暗属性的爬虫类族怪兽特殊召唤。
function c61160289.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，把自己场上2只怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61160289,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,61160289)
	e1:SetCost(c61160289.spcost)
	e1:SetTarget(c61160289.sptg)
	e1:SetOperation(c61160289.spop)
	c:RegisterEffect(e1)
	-- ②：从对方墓地有怪兽特殊召唤的场合才能发动。选对方场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61160289,1))  --"选对方场上1张卡送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61160290)
	e2:SetCondition(c61160289.tgcon)
	e2:SetTarget(c61160289.tgtg)
	e2:SetOperation(c61160289.tgop)
	c:RegisterEffect(e2)
	-- ③：从对方的手卡·卡组有怪兽被送去墓地的场合才能发动。从自己墓地选「溟界妃-阿蒙涅西娅」以外的1只光·暗属性的爬虫类族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61160289,2))  --"从自己墓地选爬虫类族怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,61160291)
	e3:SetCondition(c61160289.spcon2)
	e3:SetTarget(c61160289.sptg2)
	e3:SetOperation(c61160289.spop2)
	c:RegisterEffect(e3)
end
-- ①号效果的发动代价（Cost）处理：解放自己场上的2只怪兽
function c61160289.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp)
	-- 在chk==0时，检查是否能选出2只满足解放后仍有可用怪兽区域等条件的怪兽
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足解放条件的怪兽
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 应用代替解放等效果的次数限制
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- ①号效果的发动准备（Target）处理
function c61160289.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的效果处理（Operation）：特殊召唤自身
function c61160289.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：原本是怪兽、从对方墓地特殊召唤的卡
function c61160289.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ②号效果的发动条件：有怪兽从对方墓地特殊召唤
function c61160289.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c61160289.cfilter,1,nil,tp)
end
-- ②号效果的发动准备（Target）处理
function c61160289.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②号效果的效果处理（Operation）：选对方场上1张卡送去墓地
function c61160289.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 为选中的卡片显示被选择的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤条件：从对方的手卡或卡组送去墓地的怪兽卡
function c61160289.cfilter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- ③号效果的发动条件：对方手卡·卡组有怪兽被送去墓地
function c61160289.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c61160289.cfilter2,1,nil,tp)
end
-- 过滤条件：自己墓地中「溟界妃-阿蒙涅西娅」以外、光或暗属性的爬虫类族怪兽，且可以被特殊召唤
function c61160289.spfilter(c,e,tp)
	return not c:IsCode(61160289) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③号效果的发动准备（Target）处理
function c61160289.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c61160289.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置从墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③号效果的效果处理（Operation）：从自己墓地特殊召唤1只符合条件的怪兽
function c61160289.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件且不受王家长眠之谷影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61160289.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
