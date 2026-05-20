--幻朧竜華－霸巴
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡除外才能发动。从卡组把1张「登龙华幻胧门」加入手卡。
-- ②：这张卡是除外状态，怪兽被表侧除外的场合，若「幻胧龙华-霸巴」以外的除外状态的怪兽2只以上存在则能发动。这张卡特殊召唤。
-- ③：让自己场上1张表侧表示的「登龙华幻胧门」回到卡组最下面才能发动。「幻胧龙华-霸巴」以外的自己的卡组·墓地·除外状态的1张「龙华」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①②③效果的注册
function s.initial_effect(c)
	-- 记录该卡关联的卡片密码「登龙华幻胧门」
	aux.AddCodeList(c,55154344)
	-- ①：把这张卡从手卡除外才能发动。从卡组把1张「登龙华幻胧门」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡是除外状态，怪兽被表侧除外的场合，若「幻胧龙华-霸巴」以外的除外状态的怪兽2只以上存在则能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从除外特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：让自己场上1张表侧表示的「登龙华幻胧门」回到卡组最下面才能发动。「幻胧龙华-霸巴」以外的自己的卡组·墓地·除外状态的1张「龙华」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡组·墓地·除外状态的1张「龙华」卡加入手卡"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.thcost2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价（Cost）函数：检查并执行将手牌中的这张卡除外
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将自身作为发动代价表侧表示除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 效果①的检索过滤条件：卡名为「登龙华幻胧门」且能加入手牌
function s.thfilter(c)
	return c:IsCode(55154344) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target）函数：检查卡组中是否存在「登龙华幻胧门」，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组中是否存在至少1张满足过滤条件「登龙华幻胧门」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数：从卡组选择1张「登龙华幻胧门」加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件「登龙华幻胧门」的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的触发时点过滤条件：被除外的卡必须是表侧表示的怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动条件过滤条件：除外状态的表侧表示怪兽，且不能是同名卡「幻胧龙华-霸巴」
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end
-- 效果②的发动条件（Condition）函数：检查是否有自身以外的怪兽被表侧表示除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,e:GetHandler()) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动准备（Target）函数：检查除外状态是否存在2只以上自身以外的怪兽、自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方除外状态中是否存在至少2只自身以外的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,2,nil)
		-- 并且检查自己场上是否有空余的怪兽区域，以及这张卡自身是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息，表示该效果会特殊召唤这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）函数：将这张卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的代价过滤条件：场上表侧表示的「登龙华幻胧门」且能回到卡组
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(55154344) and c:IsAbleToDeckAsCost()
end
-- 效果③的发动代价（Cost）函数：选择自己场上1张表侧表示的「登龙华幻胧门」回到卡组最下面
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1张满足过滤条件的「登龙华幻胧门」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1张自己场上表侧表示的「登龙华幻胧门」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 选中卡片并显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡作为发动代价送回持有者卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果③的检索过滤条件：卡组、墓地、除外状态的「龙华」卡，且不能是同名卡「幻胧龙华-霸巴」
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c0) and c:IsAbleToHand()
		and not c:IsCode(id)
end
-- 效果③的发动准备（Target）函数：检查卡组、墓地、除外状态是否存在满足条件的「龙华」卡，并设置检索的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组、墓地、除外状态中是否存在至少1张满足过滤条件的「龙华」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会从卡组、墓地或除外状态将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果③的效果处理（Operation）函数：从卡组、墓地、除外状态选择1张「龙华」卡加入手牌（受王家之谷影响）
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组、墓地、除外状态中选择1张满足过滤条件且不受「王家长眠之谷」影响的「龙华」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
