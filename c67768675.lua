--正義の伝説 カイバーマン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。选自己的手卡·卡组·场上（表侧表示）·墓地3张「青眼白龙」，给双方确认。那之后，从自己的手卡·卡组·墓地把1只「青眼白龙」特殊召唤。
-- ②：这张卡在墓地存在的状态，自己把「青眼白龙」特殊召唤的场合，把这张卡除外才能发动。从卡组把1只「青眼」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①召唤·特召成功时特召「青眼白龙」的效果，以及②墓地存在时自己特召「青眼白龙」则除外自身检索「青眼」怪兽的效果
function s.initial_effect(c)
	-- 将「青眼白龙」的卡片密码注册到这张卡的关联卡片列表中
	aux.AddCodeList(c,89631139)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。选自己的手卡·卡组·场上（表侧表示）·墓地3张「青眼白龙」，给双方确认。那之后，从自己的手卡·卡组·墓地把1只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"确认"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，自己把「青眼白龙」特殊召唤的场合，把这张卡除外才能发动。从卡组把1只「青眼」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	-- 设置效果发动的Cost为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于检测手卡、卡组、场上（表侧表示）、墓地中是否存在「青眼白龙」
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsCode(89631139)
end
-- 过滤函数：用于检测手卡、卡组、墓地中是否存在可以特殊召唤的「青眼白龙」
function s.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备（Target）函数，检查手卡·卡组·场上·墓地是否有3张「青眼白龙」可供确认，且自己场上有空位，且手卡·卡组·墓地有可特召的「青眼白龙」
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、卡组、场上（表侧表示）、墓地中是否存在合计3张以上的「青眼白龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,3,nil)
		-- 检查自己场上是否有可以用于特殊召唤怪兽的空余怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地中是否存在至少1只可以特殊召唤的「青眼白龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- ①效果的运行（Operation）函数，处理确认3张「青眼白龙」并特殊召唤1只「青眼白龙」的具体流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡、卡组、场上（表侧表示）、墓地中所有的「青眼白龙」卡片组
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_DECK,0,nil)
	if g:GetCount()<3 then return end
	local rg=nil
	if g:GetCount()>3 then
		-- 提示玩家选择需要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		rg=g:Select(tp,3,3,nil)
	else
		rg=g
	end
	local cg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_DECK)
	local hg=rg-cg
	if hg:GetCount()>0 then
		-- 在场上或墓地等公开区域，为被选中的卡片显示选中动画以供确认
		Duel.HintSelection(hg)
	end
	if cg:GetCount()>0 then
		-- 将选自手卡或卡组等非公开区域的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,cg)
	end
	-- 如果被确认的卡片中包含来自卡组的卡，则洗切自己的卡组
	if rg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then Duel.ShuffleDeck(tp) end
	-- 如果被确认的卡片中包含来自手卡的卡，则洗切自己的手卡
	if rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then Duel.ShuffleHand(tp) end
	-- 检查当前自己场上是否仍有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡、卡组、墓地中选择1只满足特召条件的「青眼白龙」（受王家之谷影响）
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的特殊召唤处理与前面的确认卡片不视为同时进行（造成错时点）
			Duel.BreakEffect()
			-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：用于检测是否是由自己特殊召唤的表侧表示的「青眼白龙」
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsCode(89631139) and c:IsFaceup()
end
-- ②效果的发动条件函数，检查当前特殊召唤的怪兽中是否存在自己特殊召唤的「青眼白龙」
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数：用于检测卡组中是否存在可以加入手卡的「青眼」怪兽
function s.thfilter(c)
	return c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target）函数，检查卡组中是否存在可检索的「青眼」怪兽，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组中是否存在至少1只可以加入手卡的「青眼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的运行（Operation）函数，处理从卡组将1只「青眼」怪兽加入手牌的具体流程
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的「青眼」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
