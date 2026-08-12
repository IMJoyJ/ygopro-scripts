--機械仕掛けの夜－クロック・ワーク・ナイト－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：场上的表侧表示怪兽变成机械族。
-- ②：自己场上的机械族怪兽的攻击力·守备力上升500，对方场上的机械族怪兽的攻击力·守备力下降500。
-- ③：把墓地的这张卡除外，丢弃1张手卡才能发动。从卡组把1只机械族·地属性怪兽加入手卡。
function c84797028.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,84797028+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：场上的表侧表示怪兽变成机械族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	-- ②：自己场上的机械族怪兽的攻击力·守备力上升500，对方场上的机械族怪兽的攻击力·守备力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的目标为机械族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e3:SetValue(c84797028.val)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：把墓地的这张卡除外，丢弃1张手卡才能发动。从卡组把1只机械族·地属性怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,84797028)
	e5:SetCost(c84797028.thcost)
	e5:SetTarget(c84797028.thtg)
	e5:SetOperation(c84797028.thop)
	c:RegisterEffect(e5)
end
-- 根据怪兽的控制者返回对应的攻击力·守备力增减数值（自己场上上升500，对方场上下降500）
function c84797028.val(e,c)
	if c:IsControler(e:GetHandlerPlayer()) then return 500 else return -500 end
end
-- 检测是否能将墓地的自身除外，以及手牌中是否有可丢弃的卡，作为发动的代价
function c84797028.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检测手牌中是否存在至少1张可以丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 丢弃1张手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中可以加入手牌的机械族·地属性怪兽
function c84797028.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 检测卡组中是否存在可检索的怪兽，并设置将卡组中的卡加入手牌的操作信息
function c84797028.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在至少1只满足条件的机械族·地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84797028.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组选择1只满足条件的怪兽加入手牌，并给对方确认
function c84797028.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的机械族·地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c84797028.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
