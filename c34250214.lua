--ヴァンパイアの使い魔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从卡组把「吸血鬼的使魔」以外的1只「吸血鬼」怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把1张「吸血鬼」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c34250214.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从卡组把「吸血鬼的使魔」以外的1只「吸血鬼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34250214,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,34250214)
	e1:SetCost(c34250214.thcost)
	e1:SetTarget(c34250214.thtg)
	e1:SetOperation(c34250214.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把1张「吸血鬼」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34250214,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,34250215)
	e2:SetCost(c34250214.spcost)
	e2:SetTarget(c34250214.sptg)
	e2:SetOperation(c34250214.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价函数：以支付500基本分作为发动代价，供效果发动时调用。
function c34250214.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定阶段：检查当前玩家能否支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 代价执行阶段：实际扣除500基本分。
	Duel.PayLPCost(tp,500)
end
-- 定义检索过滤条件：从卡组中筛选「吸血鬼的使魔」以外的1只「吸血鬼」怪兽，且该卡可以加入手卡。
function c34250214.thfilter(c)
	return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and not c:IsCode(34250214) and c:IsAbleToHand()
end
-- ①效果的发动目标函数：确认卡组存在符合条件的检索对象，并设置将卡组中的卡加入手卡的操作信息。
function c34250214.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的「吸血鬼」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34250214.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果要把卡组的1张卡加入手卡，用于后续处理与发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索：提示玩家选择1只符合条件的「吸血鬼」怪兽，将其加入手卡并让对方确认。
function c34250214.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的「吸血鬼」怪兽。
	local g=Duel.SelectMatchingCard(tp,c34250214.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡（reason为效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果代价的过滤条件：选择手牌或自己场上的表侧表示卡中1张「吸血鬼」卡，可作为cost送墓，且送墓后自己场上仍有可用怪兽区用于特殊召唤。
function c34250214.costfilter(c,tp)
	-- 判定卡是否满足：属于「吸血鬼」字段，位于手牌或场上表侧表示，可作为cost送去墓地，并且送墓后仍有怪兽区空位。
	return c:IsSetCard(0x8e) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的代价函数：从手卡以及自己场上的表侧表示的卡之中选择1张「吸血鬼」卡作为cost送去墓地，并确认场上留有特殊召唤的空位。
function c34250214.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足代价条件的「吸血鬼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c34250214.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp) end
	-- 显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡和场上表侧表示卡中选择1张满足条件的「吸血鬼」卡。
	local g=Duel.SelectMatchingCard(tp,c34250214.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选择的卡作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标函数：确认这张卡可以特殊召唤，并设置特殊召唤的操作信息。
function c34250214.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果要将这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡特殊召唤；若成功，给它附加离场时除外的不被无效的效果。
function c34250214.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果仍有关联，并以表侧表示特殊召唤成功（返回数量大于0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
