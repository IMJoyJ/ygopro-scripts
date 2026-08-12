--銀河眼の雲篭
-- 效果：
-- 把这张卡解放才能发动。从自己的手卡·墓地选「银河眼云笼」以外的1只名字带有「银河眼」的怪兽特殊召唤。「银河眼云笼」的这个效果1回合只能使用1次。此外，这张卡在墓地存在的场合，自己的主要阶段时选择自己场上1只名字带有「银河眼」的超量怪兽才能发动。把墓地的这张卡在选择的怪兽下面重叠作为超量素材。「银河眼云笼」的这个效果在决斗中只能使用1次。
function c9260791.initial_effect(c)
	-- 把这张卡解放才能发动。从自己的手卡·墓地选「银河眼云笼」以外的1只名字带有「银河眼」的怪兽特殊召唤。「银河眼云笼」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9260791,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9260791)
	e1:SetCost(c9260791.spcost)
	e1:SetTarget(c9260791.sptg)
	e1:SetOperation(c9260791.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡在墓地存在的场合，自己的主要阶段时选择自己场上1只名字带有「银河眼」的超量怪兽才能发动。把墓地的这张卡在选择的怪兽下面重叠作为超量素材。「银河眼云笼」的这个效果在决斗中只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9260791,1))  --"补充素材"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,9260791+EFFECT_COUNT_CODE_DUEL)
	e2:SetTarget(c9260791.target)
	e2:SetOperation(c9260791.operation)
	c:RegisterEffect(e2)
end
-- 效果1的发动代价（Cost）函数：检查自身是否可以解放，并在发动时将自身解放
function c9260791.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·墓地中「银河眼云笼」以外的「银河眼」怪兽，且可以特殊召唤
function c9260791.spfilter(c,e,tp)
	return c:IsSetCard(0x107b) and not c:IsCode(9260791) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的发动准备（Target）函数：检查怪兽区域空位以及是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c9260791.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为Cost解放，所以空位数需要大于-1，即至少有0个空位，解放后会多出1个空位）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡或墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c9260791.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果1的效果处理（Operation）函数：从手卡·墓地选择1只符合条件的怪兽特殊召唤
function c9260791.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从手卡或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9260791.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的「银河眼」超量怪兽
function c9260791.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ)
end
-- 效果2的发动准备（Target）函数：选择自己场上1只「银河眼」超量怪兽为对象，并设置离开墓地的操作信息
function c9260791.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9260791.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的「银河眼」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c9260791.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只「银河眼」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c9260791.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置离开墓地的操作信息，表示此卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果2的效果处理（Operation）函数：将墓地的自身重叠在选择的超量怪兽下面作为超量素材
function c9260791.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象（即选择的超量怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将墓地的这张卡重叠在选择的怪兽下面作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
