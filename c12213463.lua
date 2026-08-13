--ホワイトローズ・ドラゴン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有龙族或植物族的调整存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤时才能发动。从自己的手卡·墓地把「白蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只4星以上的植物族怪兽送去墓地。
function c12213463.initial_effect(c)
	-- ①：自己场上有龙族或植物族的调整存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12213463,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12213463)
	e1:SetCondition(c12213463.spcon1)
	e1:SetTarget(c12213463.sptg1)
	e1:SetOperation(c12213463.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤时才能发动。从自己的手卡·墓地把「白蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12213463,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c12213463.sptg2)
	e2:SetOperation(c12213463.spop2)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只4星以上的植物族怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12213463,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,12213464)
	e3:SetCondition(c12213463.tgcon)
	e3:SetTarget(c12213463.tgtg)
	e3:SetOperation(c12213463.tgop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：对方场上表侧表示且为龙族或植物族的调整怪兽。
function c12213463.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON+RACE_PLANT) and c:IsType(TYPE_TUNER)
end
-- 发动条件判断：自己场上存在满足cfilter条件的表侧表示龙族或植物族调整怪兽。
function c12213463.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有至少1只符合cfilter条件的表侧表示龙族或植物族调整怪兽。
	return Duel.IsExistingMatchingCard(c12213463.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动目标判断：需要空出主要怪兽区，且这张卡自身可以被特殊召唤。
function c12213463.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将进行特殊召唤（对象为本卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：从手卡将这张卡特殊召唤到自己场上。
function c12213463.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击/守备表示特殊召唤到自己场上，不检查召唤条件和苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义过滤条件：是「蔷薇龙」怪兽、不是「白蔷薇龙」本人、且可以被特殊召唤。
function c12213463.spfilter(c,e,tp)
	return c:IsSetCard(0x1123) and not c:IsCode(12213463) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标判断：需要空出主要怪兽区，并在手卡·墓地中存在符合条件的「蔷薇龙」怪兽。
function c12213463.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在1张满足spfilter的「蔷薇龙」怪兽。
		and Duel.IsExistingMatchingCard(c12213463.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理将进行特殊召唤，对象来自手卡·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：选择手卡·墓地中1只符合条件的「蔷薇龙」怪兽特殊召唤。
function c12213463.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己主要怪兽区仍有空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中筛选出符合条件且不受王家长眠之谷影响的「蔷薇龙」怪兽，由玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12213463.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「蔷薇龙」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件：这张卡在墓地且作为同调素材被送去墓地。
function c12213463.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 定义过滤条件：等级4以上、植物族、且可以被送去墓地。
function c12213463.tgfilter(c)
	return c:IsLevelAbove(4) and c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 效果发动目标判断：卡组中存在等级4以上的植物族怪兽，并设置送去墓地的操作信息。
function c12213463.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有至少1只等级4以上且植物族的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c12213463.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把卡组中的怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只等级4以上的植物族怪兽送去墓地。
function c12213463.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中筛选出等级4以上且植物族的怪兽，由玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,c12213463.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
