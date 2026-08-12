--円卓の聖騎士
-- 效果：
-- ①：自己结束阶段，自己的场上·墓地的「圣骑士」卡种类的以下效果各能发动1次。
-- ●3种类以上：从卡组把1张「圣骑士」卡送去墓地。
-- ●6种类以上：从手卡把1只「圣骑士」怪兽特殊召唤。那之后，可以从手卡把1张「圣剑」装备魔法卡给那只怪兽装备。
-- ●9种类以上：以自己墓地1只「圣骑士」怪兽为对象才能发动。那只怪兽加入手卡。
-- ●12种类：自己从卡组抽1张。
function c55742055.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己结束阶段，自己的场上·墓地的「圣骑士」卡种类的以下效果各能发动1次。●3种类以上：从卡组把1张「圣骑士」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55742055,0))  --"从卡组把1张「圣骑士」卡送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetLabel(3)
	e2:SetCountLimit(1)
	e2:SetCondition(c55742055.effcon)
	e2:SetTarget(c55742055.target1)
	e2:SetOperation(c55742055.operation1)
	c:RegisterEffect(e2)
	-- ●6种类以上：从手卡把1只「圣骑士」怪兽特殊召唤。那之后，可以从手卡把1张「圣剑」装备魔法卡给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55742055,1))  --"从手卡把1只「圣骑士」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetLabel(6)
	e3:SetCountLimit(1)
	e3:SetCondition(c55742055.effcon)
	e3:SetTarget(c55742055.target2)
	e3:SetOperation(c55742055.operation2)
	c:RegisterEffect(e3)
	-- ●9种类以上：以自己墓地1只「圣骑士」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55742055,2))  --"选择自己墓地1只「圣骑士」怪兽加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetLabel(9)
	e4:SetCountLimit(1)
	e4:SetCondition(c55742055.effcon)
	e4:SetTarget(c55742055.target3)
	e4:SetOperation(c55742055.operation3)
	c:RegisterEffect(e4)
	-- ●12种类：自己从卡组抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(55742055,3))  --"抽1张卡"
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(c55742055.condition4)
	e5:SetTarget(c55742055.target4)
	e5:SetOperation(c55742055.operation4)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示或墓地的「圣骑士」卡
function c55742055.confilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x107a)
end
-- 效果发动条件：自己结束阶段，且自己场上·墓地的「圣骑士」卡种类（卡名数量）达到指定数值以上
function c55742055.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	if Duel.GetTurnPlayer()~=tp then return false end
	-- 获取自己场上及墓地的所有「圣骑士」卡
	local g=Duel.GetMatchingGroup(c55742055.confilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	return g:GetClassCount(Card.GetCode)>=e:GetLabel()
end
-- 过滤条件：卡组中可以送去墓地的「圣骑士」卡
function c55742055.filter1(c)
	return c:IsSetCard(0x107a) and c:IsAbleToGrave()
end
-- 3种类以上效果的发动准备：检查卡组中是否存在「圣骑士」卡，并设置送去墓地的操作信息
function c55742055.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「圣骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55742055.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 3种类以上效果的处理：从卡组选择1张「圣骑士」卡送去墓地
function c55742055.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张「圣骑士」卡
	local g=Duel.SelectMatchingCard(tp,c55742055.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡因效果送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 过滤条件：手卡中可以特殊召唤的「圣骑士」怪兽
function c55742055.filter2(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 6种类以上效果的发动准备：检查怪兽区域空位及手卡中是否存在可特召的「圣骑士」怪兽，并设置特殊召唤的操作信息
function c55742055.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡中存在至少1只可以特殊召唤的「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(c55742055.filter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置从手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤条件：手卡中可以装备给该怪兽的「圣剑」装备魔法卡
function c55742055.eqfilter(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x207a) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp)
end
-- 6种类以上效果的处理：从手卡特殊召唤1只「圣骑士」怪兽，之后可以从手卡装备1张「圣剑」装备魔法卡
function c55742055.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则处理终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c55742055.filter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧表示特殊召唤，若特殊召唤失败则处理终止
	if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取手卡中满足装备条件的「圣剑」装备魔法卡
	local tg=Duel.GetMatchingGroup(c55742055.eqfilter,tp,LOCATION_HAND,0,nil,tc,tp)
	-- 若手卡有可装备的卡、魔法与陷阱区域有空位，且玩家选择装备
	if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(55742055,4)) then  --"是否把装备魔法卡给那只怪兽装备？"
		-- 中断当前效果处理，使后续的装备处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		local sg=tg:Select(tp,1,1,nil)
		-- 将选择的装备魔法卡装备给特殊召唤的怪兽
		Duel.Equip(tp,sg:GetFirst(),tc)
	end
end
-- 过滤条件：墓地中可以加入手卡的「圣骑士」怪兽
function c55742055.thfilter(c)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 9种类以上效果的发动准备：选择自己墓地1只「圣骑士」怪兽为对象，并设置加入手卡的操作信息
function c55742055.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55742055.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的「圣骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c55742055.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「圣骑士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55742055.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将选择的对象卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 9种类以上效果的处理：将作为对象的墓地怪兽加入手卡
function c55742055.operation3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡因效果加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 12种类效果的发动条件：自己结束阶段，且自己场上·墓地的「圣骑士」卡种类刚好为12种
function c55742055.condition4(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	if Duel.GetTurnPlayer()~=tp then return false end
	-- 获取自己场上及墓地的所有「圣骑士」卡
	local g=Duel.GetMatchingGroup(c55742055.confilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	return g:GetClassCount(Card.GetCode)==12
end
-- 12种类效果的发动准备：检查自己是否可以抽卡，并设置抽卡的操作信息
function c55742055.target4(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置自己抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 12种类效果的处理：自己从卡组抽1张卡
function c55742055.operation4(e,tp,eg,ep,ev,re,r,rp)
	-- 让自己从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
