--ベビー・スパイダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只暗属性怪兽解放才能发动。自己场上的全部「小蜘蛛」的等级上升因为这个效果发动而解放的怪兽的等级数值。
-- ②：把基本分支付一半，把墓地的这张卡除外，把自己场上的暗属性超量怪兽1个超量素材取除，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c60023855.initial_effect(c)
	-- ①：把自己场上1只暗属性怪兽解放才能发动。自己场上的全部「小蜘蛛」的等级上升因为这个效果发动而解放的怪兽的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60023855,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,60023855)
	e1:SetCost(c60023855.lvcost)
	e1:SetTarget(c60023855.lvtg)
	e1:SetOperation(c60023855.lvop)
	c:RegisterEffect(e1)
	-- ②：把基本分支付一半，把墓地的这张卡除外，把自己场上的暗属性超量怪兽1个超量素材取除，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60023855,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,60023856)
	e2:SetCost(c60023855.spcost)
	e2:SetTarget(c60023855.sptg)
	e2:SetOperation(c60023855.spop)
	c:RegisterEffect(e2)
end
-- 过滤解放怪兽的条件：等级1以上、暗属性、自己场上（或表侧表示），且场上存在其他「小蜘蛛」
function c60023855.cfilter(c,tp)
	return c:IsLevelAbove(1) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查自己场上是否存在除被解放怪兽以外的表侧表示的「小蜘蛛」
		and Duel.IsExistingMatchingCard(c60023855.lvfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤等级上升对象的条件：等级1以上、表侧表示的「小蜘蛛」
function c60023855.lvfilter(c)
	return c:IsLevelAbove(1) and c:IsFaceup() and c:IsCode(60023855)
end
-- 效果①的发动代价：解放自己场上1只暗属性怪兽，并记录其在场上的等级
function c60023855.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动代价：场上是否存在可解放的满足条件的暗属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c60023855.cfilter,1,nil,tp) end
	-- 玩家选择1只满足条件的暗属性怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c60023855.cfilter,1,1,nil,tp)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetPreviousLevelOnField())
end
-- 效果①的发动准备：检查场上是否存在可以上升等级的「小蜘蛛」
function c60023855.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「小蜘蛛」
	if chk==0 then return Duel.IsExistingMatchingCard(c60023855.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果①的效果处理：使自己场上所有的「小蜘蛛」等级上升解放怪兽的等级数值
function c60023855.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=e:GetLabel()
	-- 获取自己场上所有表侧表示的「小蜘蛛」
	local g=Duel.GetMatchingGroup(c60023855.lvfilter,tp,LOCATION_MZONE,0,nil)
	if val==0 or #g==0 then return end
	-- 遍历所有符合条件的「小蜘蛛」
	for tc in aux.Next(g) do
		-- 等级上升因为这个效果发动而解放的怪兽的等级数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤取除素材怪兽的条件：表侧表示、暗属性超量怪兽，且拥有至少1个超量素材
function c60023855.ovfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 效果②的发动代价：支付一半基本分，将墓地的此卡除外，并取除自己场上1只暗属性超量怪兽的1个超量素材
function c60023855.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在可以取除超量素材的暗属性超量怪兽
		and Duel.IsExistingMatchingCard(c60023855.ovfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 将墓地的这张卡除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 玩家选择1只自己场上的暗属性超量怪兽
	local tc=Duel.SelectMatchingCard(tp,c60023855.ovfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	tc:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤特殊召唤对象的条件：墓地的暗属性怪兽且可以特殊召唤
function c60023855.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位，并选择墓地1只暗属性怪兽作为对象
function c60023855.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c60023855.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的暗属性怪兽（不含作为代价除外的此卡）
		and Duel.IsExistingTarget(c60023855.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只暗属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60023855.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的暗属性怪兽特殊召唤
function c60023855.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
