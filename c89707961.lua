--王家の守護者スフィンクス
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转召唤成功的场合发动。对方场上的怪兽全部回到持有者卡组。
-- ③：场上的这张卡被对方破坏的场合才能发动。从手卡·卡组把1只岩石族·5星怪兽里侧守备表示特殊召唤。
function c89707961.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89707961,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c89707961.postg)
	e1:SetOperation(c89707961.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转召唤成功的场合发动。对方场上的怪兽全部回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89707961,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetCountLimit(1,89707961)
	e2:SetTarget(c89707961.tdtg)
	e2:SetOperation(c89707961.tdop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被对方破坏的场合才能发动。从手卡·卡组把1只岩石族·5星怪兽里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89707961,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,89707962)
	e3:SetCondition(c89707961.spcon)
	e3:SetTarget(c89707961.sptg)
	e3:SetOperation(c89707961.spop)
	c:RegisterEffect(e3)
end
-- ①号效果（变成里侧守备表示）的发动准备与检测函数
function c89707961.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(89707961)==0 end
	c:RegisterFlagEffect(89707961,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将自身改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①号效果（变成里侧守备表示）的效果处理函数
function c89707961.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- ②号效果（对方怪兽全部回卡组）的发动准备与检测函数
function c89707961.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将对方场上的怪兽全部回到持有者卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②号效果（对方怪兽全部回卡组）的效果处理函数
function c89707961.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将对方场上的怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ③号效果（被破坏时特殊召唤）的发动条件：场上的这张卡被对方破坏
function c89707961.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手卡·卡组的岩石族·5星且可以里侧守备表示特殊召唤的怪兽
function c89707961.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ③号效果（被破坏时特殊召唤）的发动准备与检测函数
function c89707961.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有空怪兽区域，以及手卡·卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c89707961.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡·卡组将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ③号效果（被破坏时特殊召唤）的效果处理函数
function c89707961.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c89707961.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若选取的怪兽数量大于0，则将其以里侧守备表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
