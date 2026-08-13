--デーモンの超越
-- 效果：
-- 6星怪兽×2
-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
-- ②：自己场上的「恶魔召唤」被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
-- ③：超量召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
function c61248471.initial_effect(c)
	-- 为这张卡添加超量召唤手续，需要2只6星怪兽作为超量素材叠放超量召唤。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 使这张卡在怪兽区域存在期间卡名当作「恶魔召唤」（卡号70781052）使用。
	aux.EnableChangeCode(c,70781052)
	-- ②：自己场上的「恶魔召唤」被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c61248471.reptg)
	e2:SetValue(c61248471.repval)
	c:RegisterEffect(e2)
	-- ③：超量召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61248471,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c61248471.spcon)
	e3:SetTarget(c61248471.sptg)
	e3:SetOperation(c61248471.spop)
	c:RegisterEffect(e3)
end
-- 代替破坏的过滤条件：判断要破坏的卡是否是自己场上表侧表示、卡名为「恶魔召唤」、因战斗或效果破坏且不是已被代替破坏的卡。
function c61248471.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsCode(70781052) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 二效果发动条件判断：检查是否存在满足条件的「恶魔召唤」即将被破坏，且本卡可以取除1个超量素材作为代替；满足则进入询问。
function c61248471.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c61248471.repfilter,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 弹出是否发动代替破坏效果的确认框；若玩家选择是，则执行取除1个超量素材并返回真。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	end
	return false
end
-- EFFECT_DESTROY_REPLACE的值函数：根据被破坏的卡是否满足替代条件来决定是否用本卡代替其破坏。
function c61248471.repval(e,c)
	return c61248471.repfilter(c,e:GetHandlerPlayer())
end
-- 三效果发动条件：这张卡被送去墓地时，确认其之前位于怪兽区域、是以超量召唤方式召唤、被对方送去墓地且之前控制者是自己。
function c61248471.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 检索/选择过滤条件：卡名为「恶魔召唤」且可以特殊召唤的怪兽。
function c61248471.spfilter(c,e,tp)
	return c:IsCode(70781052) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 三效果发动目标判断：检查自己场上是否有怪兽区域空格，且手卡·卡组·墓地存在至少1只可特殊召唤的「恶魔召唤」。
function c61248471.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格，防止特殊召唤时无格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·卡组·墓地中是否存在至少1只符合条件的「恶魔召唤」怪兽。
		and Duel.IsExistingMatchingCard(c61248471.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，标明该效果涉及特殊召唤，且预计要从手卡·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 三效果处理：若场上有空位，让玩家从手卡·卡组·墓地选择1只符合条件的「恶魔召唤」（考虑王家长眠之谷影响），正面表示特殊召唤。
function c61248471.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用怪兽区域则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组·墓地选择1张满足条件的「恶魔召唤」（附带王家长眠之谷免疫过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61248471.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「恶魔召唤」怪兽以正面表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
