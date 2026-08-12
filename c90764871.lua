--デーモンの盤上遊戯
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：额外怪兽区域的恶魔族怪兽的攻击力上升1000。
-- ②：可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地把1只恶魔族怪兽或1张「恶魔」卡除外才能发动。从卡组把场地魔法卡以外的1张「恶魔」卡加入手卡。
-- ●从卡组把1只「恶魔」灵摆怪兽表侧加入额外卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、攻击力上升的永续效果、以及两个可选择发动的起动效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：额外怪兽区域的恶魔族怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- ●从自己的手卡·墓地把1只恶魔族怪兽或1张「恶魔」卡除外才能发动。从卡组把场地魔法卡以外的1张「恶魔」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ●从卡组把1只「恶魔」灵摆怪兽表侧加入额外卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"加入额外"
	e4:SetCategory(CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.tetg)
	e4:SetOperation(s.teop)
	c:RegisterEffect(e4)
end
-- 过滤处于额外怪兽区域（格子号大于4）且是恶魔族的怪兽，作为攻击力上升效果的影响对象。
function s.atktg(e,c)
	return c:GetSequence()>4 and c:IsRace(RACE_FIEND)
end
-- 过滤手牌或墓地中可以作为发动代价除外的「恶魔」卡或恶魔族怪兽。
function s.costfilter(c)
	return (c:IsSetCard(0x45) or c:IsRace(RACE_FIEND)) and c:IsAbleToRemoveAsCost()
end
-- 检索效果的发动代价处理：从手牌或墓地将1只恶魔族怪兽或1张「恶魔」卡表侧表示除外。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或墓地是否存在至少1张满足除外代价条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手牌或墓地选择1张满足代价条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为发动代价表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可以加入手牌的、非场地魔法卡的「恶魔」卡。
function s.thfilter(c)
	return not c:IsType(TYPE_FIELD) and c:IsSetCard(0x45) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的卡，并设置将卡加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示此效果会从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理：从卡组选择1张场地魔法卡以外的「恶魔」卡加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤卡组中的「恶魔」灵摆怪兽。
function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x45)
end
-- 加入额外卡组效果的发动准备：检查卡组中是否存在可加入额外卡组的「恶魔」灵摆怪兽，并设置操作信息。
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「恶魔」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示此效果会从卡组将1张卡送往额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 加入额外卡组效果的效果处理：从卡组选择1只「恶魔」灵摆怪兽表侧表示加入额外卡组。
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要加入额外卡组的卡"
	-- 让玩家从卡组选择1只满足条件的「恶魔」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽表侧表示送入玩家的额外卡组。
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
