--原罪宝－スネークアイ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡以外的自己场上1张表侧表示卡送去墓地才能发动。从手卡·卡组把1只炎属性·1星怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「蛇眼」怪兽或「迪亚贝尔斯塔尔」怪兽为对象才能发动。从卡组把1只炎属性·1星怪兽加入手卡。那之后，作为对象的怪兽回到卡组最下面。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：把这张卡以外的自己场上1张表侧表示卡送去墓地才能发动。从手卡·卡组把1只炎属性·1星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「蛇眼」怪兽或「迪亚贝尔斯塔尔」怪兽为对象才能发动。从卡组把1只炎属性·1星怪兽加入手卡。那之后，作为对象的怪兽回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、能送去墓地，且送去墓地后能腾出怪兽区域空格的卡。
function s.cfilter(c,tp)
	-- 检查卡片是否表侧表示、能否作为代价送去墓地，以及该卡离开场后是否有可用的怪兽区域。
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动代价处理函数。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在除这张卡以外、满足送去墓地条件的表侧表示卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	-- 将选中的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：手卡或卡组中可以特殊召唤的炎属性·1星怪兽。
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用的怪兽区域（若已支付送墓代价则无需在此判断，否则需确保有空格）。
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 检查手卡或卡组中是否存在至少1只可以特殊召唤的炎属性·1星怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表明此效果包含从手卡或卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果①的效果处理函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只满足条件的炎属性·1星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧表示特殊召唤。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：墓地中可以回到卡组的「蛇眼」怪兽或「迪亚贝尔斯塔尔」怪兽。
function s.rfilter(c)
	return c:IsSetCard(0x19c,0x119b) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤条件：卡组中可以加入手牌的炎属性·1星怪兽。
function s.sfilter(c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 效果②的发动准备、对象选择与合法性检查函数。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rfilter(chkc) end
	-- 检查自己墓地是否存在可以作为对象的「蛇眼」怪兽或「迪亚贝尔斯塔尔」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查卡组中是否存在可以加入手牌的炎属性·1星怪兽。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要回到卡组的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「蛇眼」怪兽或「迪亚贝尔斯塔尔」怪兽作为效果对象并将其设为连锁对象。
	local g=Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表明此效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息，表明此效果包含将作为对象的怪兽回到卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的效果处理函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的炎属性·1星怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选中的怪兽加入手牌，若加入手牌失败则不处理后续效果。
	if not (tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)) then return end
	-- 给对方玩家确认加入手牌的卡。
	Duel.ConfirmCards(1-tp,tc)
	-- 获取当前连锁中作为效果对象的怪兽。
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToEffect(e) then
		-- 洗切自己卡组。
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理，使后续的回到卡组最下面不与加入手牌视为同时处理。
		Duel.BreakEffect()
		-- 将作为对象的怪兽回到卡组最下面。
		Duel.SendtoDeck(rc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
