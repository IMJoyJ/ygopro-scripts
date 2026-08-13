--ゴーティスの陰影スノーピオス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从自己的手卡·墓地把2只鱼族怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡从场上离开的场合除外。
-- ③：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 定义初始效果函数，为这张卡注册三个效果：①自己/对方主要阶段从手卡·墓地除外2只鱼族怪兽自跳；②特殊召唤成功时给场上1张表侧表示卡附加离场除外的效果；③被除外时从墓地除外1只鱼族怪兽将自身加入手卡。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，从自己的手卡·墓地把2只鱼族怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.flagtg)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：仅在当前为主要阶段1或主要阶段2时才能发动（对应“自己·对方的主要阶段”）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否等于主要阶段1或主要阶段2，满足任一即为主要阶段。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 代价筛选函数：用于挑选可作为代价除外的鱼族怪兽，条件是种族为鱼族且可以被除外作为代价。
function s.costfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价：从自己的手卡·墓地选择除自身以外的2只鱼族怪兽除外才能发动；本函数先检查再执行选择与除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：确认自己的手卡·墓地中是否存在除自身以外的至少2只鱼族怪兽可作为代价除外，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,c) end
	-- 发出选择提示，要求当前玩家选择要除外的卡（此处用于选择①的代价怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的手卡·墓地中，排除自身，选择2张满足条件的鱼族怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,c)
	-- 将选中的2张鱼族怪兽以表侧表示除外，作为①效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标处理：确认自己场上有可用怪兽区且自身可以被特殊召唤，然后设置将自身特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 目标检查：自己的主要怪兽区有空位，且这张卡能够被特殊召唤，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将进行特殊召唤，对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：在效果处理时若这张卡仍与效果关联，则将这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到当前玩家的主要怪兽区，以通常的特殊召唤规则进行检查。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的目标处理：选择场上1张表侧表示卡为对象（取对象），并设置对象选择；发动的场合需要场上存在表侧表示卡。
function s.flagtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 目标检查：场上是否存在至少1张表侧表示卡可以作为②效果的对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 发出选择提示，要求玩家选择场上的表侧表示卡（用于②效果的对象选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方场上选择1张表侧表示卡作为②效果的对象，并建立该卡与连锁的关联（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果的处理：为对象卡附加“从场上离开的场合除外”的效果；若对象已不关联则处理不适用。
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 那张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))  --"「魊影的阴影 斯诺皮奥斯」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	tc:RegisterEffect(e1)
end
-- ③效果的代价：从自己的墓地选择1只鱼族怪兽除外才能发动；本函数负责检查、选择并除外代价怪兽。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己的墓地中是否存在至少1只鱼族怪兽可作为代价除外。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发出选择提示，要求当前玩家选择要除外的卡（此处用于选择③的代价怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的墓地选择1张满足条件的鱼族怪兽作为③的代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的鱼族怪兽以表侧表示除外，作为③效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果的目标处理：确认这张卡能够加入手卡，并设置将自身回手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：本次处理会将这张卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ③效果的处理：若这张卡仍与效果关联，则将其加入持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡送到持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
