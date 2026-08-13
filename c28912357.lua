--ギアギガント X
-- 效果：
-- 机械族4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只4星以下的机械族怪兽加入手卡。
-- ②：表侧表示的这张卡从场上离开时，以自己墓地1只3星以下的「齿轮齿轮」怪兽为对象才能发动。那只怪兽特殊召唤。
function c28912357.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只4星机械族怪兽作为超量素材叠放来XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只4星以下的机械族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(28912357,0))  --"加入手卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28912357.cost)
	e1:SetTarget(c28912357.target)
	e1:SetOperation(c28912357.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡从场上离开时，以自己墓地1只3星以下的「齿轮齿轮」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28912357,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c28912357.spcon)
	e2:SetTarget(c28912357.sptg)
	e2:SetOperation(c28912357.spop)
	c:RegisterEffect(e2)
end
-- 发动代价的检测与执行：检测时返回能否取除1个超量素材；执行时实际取除这张卡的1个超量素材作为代价。
function c28912357.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件：4星以下、机械族、且可以被加入手卡（不受“不能加入手卡”限制）。
function c28912357.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 发动时判定：自己的卡组·墓地是否存在符合条件的机械族怪兽；若存在，则设置本次效果将1张卡从卡组·墓地加入手卡的操作信息。
function c28912357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己的卡组·墓地存在至少1只4星以下的机械族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28912357.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果涉及将1张卡从卡组·墓地加入手卡（用于连锁判定和效果发动检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理：提示玩家选择要加入手卡的卡，从自己的卡组·墓地选择1只符合条件的机械族怪兽（墓地侧受王家长眠之谷影响时不可选），将其加入手卡并向对方展示。
function c28912357.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示文本为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组·墓地选择1张满足条件的机械族怪兽，且过滤受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28912357.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：这张卡在离场前是表侧表示且停留在场上（即表侧表示的这张卡从场上离开时）。
function c28912357.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选特召对象：3星以下的「齿轮齿轮」怪兽，且可以被当前效果特殊召唤。
function c28912357.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x72) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的取对象发动处理：检查自己主要怪兽区是否有空位，并选择自己墓地1只符合条件的「齿轮齿轮」怪兽作为对象。
function c28912357.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28912357.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有可用空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件的「齿轮齿轮」怪兽可以作为特殊召唤的对象。
		and Duel.IsExistingTarget(c28912357.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示文本为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的「齿轮齿轮」怪兽，并将其登记为当前连锁的取对象。
	local g=Duel.SelectTarget(tp,c28912357.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理时会将选择的对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若其仍与效果关联，将其以表侧表示特殊召唤到自己场上。
function c28912357.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选定的对象卡（即自己墓地的「齿轮齿轮」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，不进行召唤条件/苏生限制检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
