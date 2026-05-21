--ワルキューレ・シグルーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡送去墓地，这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只8星以下的「女武神」怪兽特殊召唤。
function c97854941.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97854941,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,97854941)
	e1:SetTarget(c97854941.sptg1)
	e1:SetOperation(c97854941.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只8星以下的「女武神」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97854941,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,97854942)
	e2:SetTarget(c97854941.sptg2)
	e2:SetOperation(c97854941.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示且送去墓地后能让自身特殊召唤的魔法·陷阱卡
function c97854941.tgfilter(c,tp)
	-- 过滤条件：表侧表示的魔法·陷阱卡，且该卡送去墓地后自己场上有可用的怪兽区域，且能送去墓地
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGrave()
end
-- 效果①的发动准备与对象选择
function c97854941.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c97854941.tgfilter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的表侧表示魔法·陷阱卡，以及手牌中的这张卡是否能特殊召唤
	if chk==0 then return Duel.IsExistingTarget(c97854941.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张表侧表示的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c97854941.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：包含将对象卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置操作信息：包含将这张卡特殊召唤的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的执行：将对象卡送去墓地，这张卡特殊召唤
function c97854941.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍对应效果，若成功送去墓地且确实到达墓地，且手牌中的这张卡仍对应效果
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手牌·墓地中8星以下的「女武神」怪兽
function c97854941.spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsSetCard(0x122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备
function c97854941.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在可以特殊召唤的8星以下「女武神」怪兽
		and Duel.IsExistingMatchingCard(c97854941.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：包含从手牌或墓地特殊召唤怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的执行：从手牌·墓地特殊召唤1只8星以下的「女武神」怪兽
function c97854941.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择1只满足条件的「女武神」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97854941.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
