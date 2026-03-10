--クリムゾン・ブレーダー／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。把1张「爆裂模式」或者有那个卡名记述的卡从卡组加入手卡，这张卡回到卡组。
-- ②：对方不能把从额外卡组特殊召唤的5星以上的怪兽的效果发动。
-- ③：这张卡被破坏的场合才能发动。从自己墓地把1只「深红剑士」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册相关卡号并设置特殊召唤条件
function s.initial_effect(c)
	-- 记录该卡具有「爆裂模式」和「深红剑士」的卡名记述
	aux.AddCodeList(c,80280737,80321197)
	-- 设置该卡的特殊召唤条件为只能通过「爆裂模式」效果特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 使用辅助函数限制特殊召唤方式为「爆裂模式」或特定来源
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- 设置①效果：检索满足条件的卡并返回手牌，同时将自身送回卡组
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 设置②效果：禁止对方发动从额外卡组特殊召唤的5星以上怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	-- 设置③效果：破坏时特殊召唤墓地的「深红剑士」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.assault_name=80321197
-- ①效果的费用支付函数，检查是否已公开手牌
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤器函数，用于筛选「爆裂模式」或记述该卡名的卡
function s.thfilter(c)
	-- 判断卡片是否为「爆裂模式」或记述该卡名且能加入手牌
	return aux.IsCodeOrListed(c,80280737) and c:IsAbleToHand()
end
-- ①效果的发动条件判断，检查是否有满足条件的卡可检索且自身可送回卡组
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否存在满足检索条件的卡且自身可送回卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck() end
	-- 设置操作信息，提示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数，选择卡并执行检索和送回卡组操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡进行检索
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将自身送回卡组并洗牌
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- ②效果的限制函数，判断是否为从额外卡组特殊召唤的5星以上怪兽
function s.aclimit(e,re)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLevelAbove(5) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_EXTRA)
end
-- ③效果的发动条件判断，检查是否有可特殊召唤的「深红剑士」且场上存在空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足特殊召唤条件的「深红剑士」且场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，提示将从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果的过滤器函数，用于筛选可特殊召唤的「深红剑士」
function s.spfilter(c,e,tp)
	return c:IsCode(80321197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的处理函数，选择并执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「深红剑士」进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
