--地縛超神官
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：同调怪兽在自己的场上·墓地的两方存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1只「地缚神」怪兽加入手卡。
-- ③：这张卡已在怪兽区域存在的状态，「地缚神」怪兽召唤的场合才能发动。对方基本分变成3000。
function c45836982.initial_effect(c)
	-- ①：同调怪兽在自己的场上·墓地的两方存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45836982)
	e1:SetCondition(c45836982.spcon)
	e1:SetTarget(c45836982.sptg)
	e1:SetOperation(c45836982.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1只「地缚神」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,45836983)
	e2:SetTarget(c45836982.thtg)
	e2:SetOperation(c45836982.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡已在怪兽区域存在的状态，「地缚神」怪兽召唤的场合才能发动。对方基本分变成3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,45836984)
	e3:SetCondition(c45836982.lpcon)
	e3:SetOperation(c45836982.lpop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡片为表侧表示且为同调怪兽，用于匹配场上表侧表示的同调怪兽。
function c45836982.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ①效果的发动条件：自己场上有表侧表示的同调怪兽，且自己墓地存在同调怪兽。
function c45836982.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的同调怪兽。
	return Duel.IsExistingMatchingCard(c45836982.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在至少1只同调怪兽。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SYNCHRO)
end
-- ①效果发动前的合法性检查：自己主要怪兽区有空位，且这张卡可以被特殊召唤；并在合法时设置特殊召唤的操作信息。
function c45836982.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将这张卡特殊召唤的操作信息，用于效果发动时的连锁预告。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时：若这张卡仍与效果关联，则将其从手卡特殊召唤到自己场上。
function c45836982.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧表示（POS_FACEUP）将这张卡特殊召唤到其控制者（tp）的怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡名属于「地缚神」系列的怪兽卡，且可以被加入手卡（不受加入手卡限制）。
function c45836982.thfilter(c)
	return c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果发动时的检查：卡组·墓地中是否存在符合条件的「地缚神」怪兽；并设置将其加入手卡的操作信息。
function c45836982.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组·墓地是否存在至少1张符合条件的「地缚神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45836982.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置将1张「地缚神」怪兽从卡组·墓地加入手卡的操作信息，目标位置为卡组和墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理时：从自己的卡组·墓地选择1张符合条件的「地缚神」怪兽加入手卡，并让对方确认该卡。
function c45836982.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡（显示选择框提示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1张满足条件且不受「王家长眠之谷」影响的「地缚神」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45836982.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示（确认）加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：卡片为表侧表示且属于「地缚神」系列怪兽，用于判断召唤成功的怪兽是否为「地缚神」。
function c45836982.lpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1021)
end
-- ③效果的发动条件：对方基本分不是3000，且本次召唤成功的怪兽中不包含这张卡自身，且包含表侧表示的「地缚神」怪兽。
function c45836982.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方LP是否为非3000、召唤成功怪兽中是否不包含此卡、是否存在表侧表示「地缚神」怪兽。
	return Duel.GetLP(1-tp)~=3000 and not eg:IsContains(e:GetHandler()) and eg:IsExists(c45836982.lpfilter,1,nil)
end
-- ③效果处理时：将对方基本分变成3000。
function c45836982.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方玩家（1-tp）的基本分设置为3000。
	Duel.SetLP(1-tp,3000)
end
