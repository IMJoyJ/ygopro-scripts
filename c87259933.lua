--宝玉の集結
-- 效果：
-- 这张卡的①②的效果在同一连锁上不能发动。
-- ①：1回合1次，自己场上的表侧表示的「宝玉兽」怪兽被战斗·效果破坏的场合才能发动。从卡组把1只「宝玉兽」怪兽特殊召唤。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己场上1张「宝玉兽」卡和场上1张卡为对象才能发动。那些卡回到持有者手卡。
function c87259933.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的表侧表示的「宝玉兽」怪兽被战斗·效果破坏的场合才能发动。从卡组把1只「宝玉兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87259933,1))  --"发动并使用②效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c87259933.spcon)
	e2:SetTarget(c87259933.sptg)
	e2:SetOperation(c87259933.spop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己场上1张「宝玉兽」卡和场上1张卡为对象才能发动。那些卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87259933,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c87259933.thcost)
	e3:SetTarget(c87259933.thtg)
	e3:SetOperation(c87259933.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「宝玉兽」怪兽因战斗或效果被破坏
function c87259933.cfilter(c,tp)
	return c:IsSetCard(0x1034) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 检查因战斗或效果被破坏的卡中是否存在自己场上表侧表示的「宝玉兽」怪兽
function c87259933.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87259933.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中可以特殊召唤的「宝玉兽」怪兽
function c87259933.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备（检查怪兽区域空位、卡组中是否存在可特召的「宝玉兽」怪兽，并设置特殊召唤的操作信息）
function c87259933.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「宝玉兽」怪兽
		and Duel.IsExistingMatchingCard(c87259933.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理（从卡组选择1只「宝玉兽」怪兽特殊召唤到场上）
function c87259933.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「宝玉兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c87259933.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动代价（将魔法与陷阱区域表侧表示的这张卡送去墓地）
function c87259933.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤条件1：自己场上表侧表示且可以回到手牌的「宝玉兽」卡，且场上存在另一张可以回到手牌的卡
function c87259933.thfilter1(c,rc)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToHand()
		-- 检查场上是否存在另一张不等于当前选择的卡且可以回到手牌的卡
		and Duel.IsExistingTarget(c87259933.thfilter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,rc)
end
-- 过滤条件2：不等于第一张选择的卡且可以回到手牌的场上的卡
function c87259933.thfilter2(c,rc)
	return c~=rc and c:IsAbleToHand()
end
-- ②号效果的发动准备（检查同一连锁上是否已发动此卡的效果，并选择自己场上1张「宝玉兽」卡和场上1张卡作为对象）
function c87259933.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否存在满足条件的「宝玉兽」卡作为第一个对象
		and Duel.IsExistingTarget(c87259933.thfilter1,tp,LOCATION_ONFIELD,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡（第一个对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张表侧表示的「宝玉兽」卡作为第一个对象
	local g1=Duel.SelectTarget(tp,c87259933.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,e:GetHandler())
	-- 提示玩家选择要返回手牌的卡（第二个对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡（不能是第一个对象）作为第二个对象
	local g2=Duel.SelectTarget(tp,c87259933.thfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst(),e:GetHandler())
	g1:Merge(g2)
	-- 设置将选择的2张卡送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②号效果的处理（将作为对象的卡送回持有者手牌）
function c87259933.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
