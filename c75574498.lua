--プリンセス・コロン
-- 效果：
-- 4星怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地1只「玩具盒」为对象才能发动。那只怪兽特殊召唤。
-- ②：只要自己场上有其他怪兽存在，对方不能选择这张卡作为攻击对象，也不能作为效果的对象。
-- ③：自己场上的表侧表示的通常怪兽被战斗·效果破坏送去墓地的场合，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只通常怪兽守备表示特殊召唤。
function c75574498.initial_effect(c)
	-- 设置该卡超量召唤的手续：4星怪兽2只。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地1只「玩具盒」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75574498,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c75574498.spcon)
	e1:SetTarget(c75574498.sptg)
	e1:SetOperation(c75574498.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有其他怪兽存在，对方不能选择这张卡作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(c75574498.tgcon)
	-- 设置不能成为攻击对象效果的过滤函数（自身不会被选择为攻击对象）。
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为对方效果对象效果的过滤函数（自身不会被对方选择为效果对象）。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：自己场上的表侧表示的通常怪兽被战斗·效果破坏送去墓地的场合，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只通常怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75574498,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c75574498.spcon2)
	e4:SetCost(c75574498.spcost2)
	e4:SetTarget(c75574498.sptg2)
	e4:SetOperation(c75574498.spop2)
	c:RegisterEffect(e4)
end
-- 判定此卡是否为超量召唤成功，作为效果①的发动条件。
function c75574498.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤自己墓地中可以特殊召唤的「玩具盒」。
function c75574498.spfilter1(c,e,tp)
	return c:IsCode(81587028) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择（检查怪兽区域空位、墓地是否存在「玩具盒」并进行取对象）。
function c75574498.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c75574498.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以特殊召唤的「玩具盒」作为效果对象。
		and Duel.IsExistingTarget(c75574498.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只「玩具盒」作为效果对象。
	local g=Duel.SelectTarget(tp,c75574498.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息，表示将特殊召唤1张选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（将作为对象的「玩具盒」特殊召唤）。
function c75574498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①中被选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定自己场上是否存在其他怪兽，作为效果②的适用条件。
function c75574498.tgcon(e)
	-- 检查自己场上的怪兽数量是否大于等于2（即除了自身以外还有其他怪兽存在）。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>=2
end
-- 过滤自己场上因战斗或效果破坏送去墓地的表侧表示通常怪兽。
function c75574498.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_NORMAL)~=0
end
-- 判定是否有符合条件的通常怪兽被破坏送去墓地，作为效果③的发动条件。
function c75574498.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c75574498.cfilter,1,nil,tp)
end
-- 效果③的代价处理（取除此卡的1个超量素材）。
function c75574498.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组或墓地中可以守备表示特殊召唤的通常怪兽。
function c75574498.spfilter2(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果③的发动准备（检查怪兽区域空位、卡组或墓地是否存在可特殊召唤的通常怪兽）。
function c75574498.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组或墓地是否存在至少1只可以守备表示特殊召唤的通常怪兽。
		and Duel.IsExistingMatchingCard(c75574498.spfilter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示将从卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果③的效果处理（从卡组或墓地选择1只通常怪兽守备表示特殊召唤）。
function c75574498.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组或墓地（受王家长眠之谷影响）选择1只符合条件的通常怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75574498.spfilter2),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的通常怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
