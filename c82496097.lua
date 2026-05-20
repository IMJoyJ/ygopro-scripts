--クロノダイバー・ベゼルシップ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从对方墓地选1张卡在作为对象的怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，把自己场上1个超量素材取除才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c82496097.initial_effect(c)
	-- ①：把这张卡解放，以自己场上1只「时间潜行者」超量怪兽为对象才能发动。从对方墓地选1张卡在作为对象的怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82496097,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,82496097)
	e1:SetCost(c82496097.matcost)
	e1:SetTarget(c82496097.mattg)
	e1:SetOperation(c82496097.matop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己场上1个超量素材取除才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82496097,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,82496098)
	e2:SetCost(c82496097.spcost)
	e2:SetTarget(c82496097.sptg)
	e2:SetOperation(c82496097.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价：检查自身是否能解放，并解放自身。
function c82496097.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的「时间潜行者」超量怪兽。
function c82496097.matfilter(c)
	return c:IsSetCard(0x126) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- ①号效果的发动准备与靶向：检查场上是否存在符合条件的「时间潜行者」超量怪兽，以及对方墓地是否有可以作为超量素材的卡，并选择对象。
function c82496097.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c82496097.matfilter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「时间潜行者」超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c82496097.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且对方墓地存在至少1张可以重叠作为超量素材的卡。
		and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「时间潜行者」超量怪兽作为对象。
	Duel.SelectTarget(tp,c82496097.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①号效果的处理：获取对象怪兽，若其仍适用，则从对方墓地选择1张卡重叠作为其超量素材。
function c82496097.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从对方墓地选择1张可以作为超量素材的卡（适用王家长眠之谷的过滤）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanOverlay),tp,0,LOCATION_GRAVE,1,1,nil)
		-- 将选中的卡在作为对象的怪兽下面重叠作为超量素材。
		Duel.Overlay(tc,g)
	end
end
-- ②号效果的发动代价：检查并取除自己场上1个超量素材。
function c82496097.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1个可以取除的超量素材。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 取除自己场上1个超量素材作为发动代价。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- ②号效果的发动准备：检查自己场上是否有空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息。
function c82496097.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置当前连锁的操作信息为“特殊召唤自身”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②号效果的处理：将自身特殊召唤，并添加“从场上离开的场合除外”的永续效果。
function c82496097.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
