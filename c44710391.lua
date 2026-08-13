--地縛地上絵
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要场上有10星怪兽存在，这张卡不会被效果破坏，双方不能把这张卡作为效果的对象。
-- ②：只要这张卡在场地区域存在，自己把「地缚神」怪兽上级召唤的场合，同调怪兽可以作为2只的数量解放。
-- ③：同调怪兽特殊召唤的场合才能发动。从卡组把1张「地缚神」魔法·陷阱卡加入手卡。
function c44710391.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要场上有10星怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c44710391.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，自己把「地缚神」怪兽上级召唤的场合，同调怪兽可以作为2只的数量解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c44710391.dttg)
	e4:SetValue(c44710391.dtval)
	c:RegisterEffect(e4)
	-- 这个卡名的③的效果1回合只能使用1次。③：同调怪兽特殊召唤的场合才能发动。从卡组把1张「地缚神」魔法·陷阱卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(44710391,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,44710391)
	e5:SetCondition(c44710391.condition)
	e5:SetTarget(c44710391.target)
	e5:SetOperation(c44710391.operation)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断怪兽是否为表侧表示且等级为10，用于①效果中确认场上是否存在10星怪兽。
function c44710391.indfilter(c)
	return c:IsFaceup() and c:IsLevel(10)
end
-- ①效果的条件函数：检查双方场上是否存在至少1只表侧等级10的怪兽，若存在则效果适用。
function c44710391.indcon(e)
	-- 实际检测：以全场为范围，查找是否存在至少1张满足表侧等级10过滤条件的怪兽。
	return Duel.IsExistingMatchingCard(c44710391.indfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 筛选可作为2只数量解放的怪兽：怪兽为同调怪兽，且为表侧表示或由效果持有者控制。
function c44710391.dttg(e,c)
	return c:IsType(TYPE_SYNCHRO) and (c:IsFaceup() or c:IsControler(e:GetHandlerPlayer()))
end
-- EFFECT_DOUBLE_TRIBUTE 的判定函数：当上级召唤的怪兽为「地缚神」且由效果持有者控制时，允许同调怪兽作为2只数量解放。
function c44710391.dtval(e,c)
	return c:IsSetCard(0x1021) and c:IsControler(e:GetHandlerPlayer())
end
-- ③效果的发动条件：本次特殊召唤成功的怪兽中存在至少1只同调怪兽。
function c44710391.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- 检索过滤：卡片为「地缚神」字段的魔法·陷阱卡，且能够加入手牌。
function c44710391.thfilter(c)
	return c:IsSetCard(0x1021) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③效果的发动时处理：确认卡组有符合条件的检索对象，并设置加入手牌的操作信息。
function c44710391.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：chk==0 时确认卡组是否存在至少1张符合条件的「地缚神」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44710391.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：标明本次效果处理为从卡组将1张卡加入手牌（用于后续效果响应检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：提示选择并执行检索，将符合条件的「地缚神」魔法·陷阱卡加入手牌并展示给对方。
function c44710391.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「地缚神」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c44710391.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
