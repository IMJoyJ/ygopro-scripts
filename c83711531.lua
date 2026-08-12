--真紅眼の鋼爪竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1张里侧表示卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，若自己的场上或墓地有「金属化·强化反射装甲」存在则能发动。从自己的卡组·墓地把1张「金属化」陷阱卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己让「金属化」陷阱卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含特殊召唤、检索「金属化」陷阱卡以及允许盖放回合发动「金属化」陷阱卡的效果
function s.initial_effect(c)
	-- 将「金属化·强化反射装甲」注册到该卡的关联卡片密码列表中
	aux.AddCodeList(c,89812483)
	-- ①：把自己场上1张里侧表示卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合，若自己的场上或墓地有「金属化·强化反射装甲」存在则能发动。从自己的卡组·墓地把1张「金属化」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，自己让「金属化」陷阱卡在盖放的回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"适用「真红眼钢爪龙」的效果来发动"
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.qfilter)
	c:RegisterEffect(e4)
end
-- 过滤自身场上里侧表示、且能作为Cost送去墓地，并且送去墓地后能腾出怪兽区域供特殊召唤的卡片
function s.costfilter(c,tp)
	return c:IsFacedown()
		-- 检查卡片是否能作为Cost送去墓地，且该卡离开场上后，玩家场上是否有可用的主要怪兽区域
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的Cost函数：检查并选择自己场上1张里侧表示的卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张满足条件的里侧表示卡片作为Cost
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足条件的里侧表示卡片
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 将选择的卡片作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的Target函数：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的Operation函数：将手牌中的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤卡组或墓地中属于「金属化」系列的陷阱卡，且该卡能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的Target函数：检查场上或墓地是否存在「金属化·强化反射装甲」，且卡组或墓地是否有可检索的「金属化」陷阱卡，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的场上（表侧表示）或墓地是否存在「金属化·强化反射装甲」
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,89812483)
		-- 检查自己的卡组或墓地是否存在可以加入手牌的「金属化」陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置加入手牌的操作信息，表示从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的Operation函数：从卡组或墓地选择1张「金属化」陷阱卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「金属化」陷阱卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片通过效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤属于「金属化」系列的卡片，用于确定哪些盖放的陷阱卡可以在盖放的回合发动
function s.qfilter(e,c)
	return c:IsSetCard(0x1ba)
end
