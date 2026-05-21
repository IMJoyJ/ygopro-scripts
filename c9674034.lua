--スネークアイ・エクセル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只炎属性·1星怪兽加入手卡。
-- ②：把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼梣树灵」以外的1只「蛇眼」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含召唤·特殊召唤成功时检索炎属性·1星怪兽的效果，以及送墓场上2张表侧表示卡特殊召唤「蛇眼」怪兽的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只炎属性·1星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼梣树灵」以外的1只「蛇眼」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中等级1且是炎属性且可以加入手牌的怪兽
function s.filter(c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 效果①（检索炎属性·1星怪兽）的发动准备与合法性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索炎属性·1星怪兽）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上可以作为代价送去墓地的表侧表示卡，并确保送墓后有足够的怪兽区域用于特殊召唤
function s.cfilter(c,tc,tp)
	-- 检查卡片是否在场上表侧表示、能否作为代价送去墓地，且在将该卡和自身送去墓地后，自己场上是否有可用的怪兽区域
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,tc))>0
end
-- 效果②（特殊召唤「蛇眼」怪兽）的发动代价处理函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动准备阶段，检查自身是否能作为代价送去墓地，且场上是否存在另一张满足条件的卡可以一同送去墓地
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,c,tp) end
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从场上选择1张满足条件的卡，并与自身（这张卡）组合成一个卡片组
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,c,tp)+c
	-- 将选定的2张卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤手牌或卡组中除「蛇眼梣树灵」以外、可以被特殊召唤的「蛇眼」怪兽
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x19c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 效果②（特殊召唤「蛇眼」怪兽）的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查是否已支付代价，或者当前自己场上是否有可用的怪兽区域
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 并且检查手牌或卡组中是否存在至少1只满足过滤条件的「蛇眼」怪兽
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手牌或卡组将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②（特殊召唤「蛇眼」怪兽）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组中选择1只满足过滤条件的「蛇眼」怪兽
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
