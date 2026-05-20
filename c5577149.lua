--バーバリアン0号
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「蛮族的狂宴LV5」加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的「野蛮人」怪兽的攻击力上升500。
-- ③：把这张卡解放才能发动。从手卡把1只战士族·8星怪兽特殊召唤。
local s,id,o=GetID()
-- 效果注册的初始化函数，包含①②③效果的注册
function c5577149.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「蛮族的狂宴LV5」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5577149,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,5577149)
	e1:SetTarget(c5577149.thtg)
	e1:SetOperation(c5577149.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「野蛮人」怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的适用对象为「野蛮人」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x17b))
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- ③：把这张卡解放才能发动。从手卡把1只战士族·8星怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5577149,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,5577149+o)
	e4:SetCost(c5577149.spcost)
	e4:SetTarget(c5577149.sptg)
	e4:SetOperation(c5577149.spop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中卡名为「蛮族的狂宴LV5」且能加入手牌的卡
function c5577149.thfilter(c)
	return c:IsCode(55416843) and c:IsAbleToHand()
end
-- ①效果的发动条件检查与效果处理信息设置
function c5577149.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「蛮族的狂宴LV5」
	if chk==0 then return Duel.IsExistingMatchingCard(c5577149.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组将1张「蛮族的狂宴LV5」加入手牌并给对方确认
function c5577149.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「蛮族的狂宴LV5」
	local g=Duel.SelectMatchingCard(tp,c5577149.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动代价：解放自身，并检查解放后是否有可用的怪兽区域
function c5577149.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否可以解放，以及解放此卡后是否能腾出可用的怪兽区域
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 解放自身作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤手牌中可以特殊召唤的战士族·8星怪兽
function c5577149.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件检查与效果处理信息设置
function c5577149.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以特殊召唤的战士族·8星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5577149.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示该效果会从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果的实际处理：从手牌将1只战士族·8星怪兽特殊召唤
function c5577149.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的战士族·8星怪兽
	local g=Duel.SelectMatchingCard(tp,c5577149.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
