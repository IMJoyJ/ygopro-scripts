--霊魂の拠所
-- 效果：
-- 「灵魂的据所」的②的效果1回合只能使用1次。
-- ①：自己场上的灵魂怪兽的攻击力·守备力上升500。
-- ②：自己场上的表侧表示的风属性怪兽回到自己手卡的场合才能发动。从卡组把1只灵魂怪兽或者1张仪式魔法卡加入手卡。
function c9553721.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的灵魂怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为灵魂怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 「灵魂的据所」的②的效果1回合只能使用1次。②：自己场上的表侧表示的风属性怪兽回到自己手卡的场合才能发动。从卡组把1只灵魂怪兽或者1张仪式魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9553721,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_HAND)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,9553721)
	e4:SetCondition(c9553721.thcon)
	e4:SetTarget(c9553721.thtg)
	e4:SetOperation(c9553721.thop)
	c:RegisterEffect(e4)
end
c9553721.has_text_type=TYPE_SPIRIT
-- 过滤条件：回到手卡前在自己场上表侧表示存在的风属性怪兽
function c9553721.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0
		and c:IsPreviousPosition(POS_FACEUP) and c:IsControler(tp)
end
-- 发动条件：检查回到手卡的卡中是否存在满足过滤条件的卡
function c9553721.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9553721.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中的灵魂怪兽或仪式魔法卡
function c9553721.thfilter(c)
	return (c:IsType(TYPE_SPIRIT) or c:GetType()==0x82) and c:IsAbleToHand()
end
-- 效果发动阶段：检查卡组中是否存在可检索的卡，并设置操作信息为将1张卡从卡组加入手卡
function c9553721.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9553721.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组选择1张灵魂怪兽或仪式魔法卡加入手卡，并给对方确认
function c9553721.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c9553721.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
