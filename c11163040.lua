--壊獣の出現記録
-- 效果：
-- ①：每次从手卡·墓地有「坏兽」怪兽特殊召唤给这张卡放置1个坏兽指示物（最多5个）。
-- ②：1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽破坏，那之后，原本卡名和破坏的那只怪兽不同的1只「坏兽」怪兽从自己卡组往那个控制者场上特殊召唤。
-- ③：把坏兽指示物是3个以上的这张卡送去墓地才能发动。从卡组把「坏兽的出现记录」以外的1张「坏兽」魔法·陷阱卡加入手卡。
function c11163040.initial_effect(c)
	c:EnableCounterPermit(0x37)
	c:SetCounterLimit(0x37,5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ● 效果①：放置指示物
每次从手牌·墓地有「坏兽」怪兽特殊召唤，给这张卡放置1个坏兽指示物（最多5个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11163040.counter)
	c:RegisterEffect(e2)
	-- ● 效果②：破坏场上「坏兽」并从卡组特召同名以外的「坏兽」
1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽破坏。那之后，原本卡名和破坏的怪兽不同的1只「坏兽」怪兽从卡组往那个控制者场上表侧表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11163040,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c11163040.target)
	e3:SetOperation(c11163040.operation)
	c:RegisterEffect(e3)
	-- ● 效果③：送去墓地检索「坏兽」魔陷
③：把坏兽指示物是3个以上的这张卡送去墓地才能发动。从卡组把「坏兽的出现记录」以外的1张「坏兽」魔法·陷阱卡加入手牌。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11163040,1))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c11163040.thcon)
	e4:SetCost(c11163040.thcost)
	e4:SetTarget(c11163040.thtg)
	e4:SetOperation(c11163040.thop)
	c:RegisterEffect(e4)
end
c11163040.mentioned_counter={
	[0x37]=true,
}
-- 筛选从手牌或墓地特殊召唤的「坏兽」怪兽。
function c11163040.cfilter(c)
	return c:IsSetCard(0xd3) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- 当有符合条件的坏兽被特殊召唤时，为这张卡放置1个坏兽指示物。
function c11163040.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c11163040.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x37,1)
	end
end
-- 筛选场上表侧表示的「坏兽」怪兽，且卡组中存在可特召的不同名坏兽。
function c11163040.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd3)
		-- 检查卡组中是否存在原本卡名不同且能特召到对应控制者场上的坏兽。
		and Duel.IsExistingMatchingCard(c11163040.chkfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetControler(),c:GetOriginalCodeRule())
end
-- 确认卡组中的坏兽是否符合特召规则（非同名、无复活限制且允许特召）。
function c11163040.chkfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCodeRule(code) and
		-- 确认怪兽没有复活限制且玩家可以在目标区域表侧表示特召。
		not c:IsHasEffect(EFFECT_REVIVE_LIMIT) and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,cc,c)
end
-- 筛选卡组中可特殊召唤至指定控制者场上的不同名坏兽。
function c11163040.spfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,cc)
end
-- 效果②的目标选择与确认。
function c11163040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11163040.filter(chkc,e,tp) end
	-- 检查自己场上破坏后是否有足够的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己场上是否存在合法的「坏兽」目标。
		and Duel.IsExistingTarget(c11163040.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上破坏后是否有足够的怪兽区域空位。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-1
		-- 检查对方场上是否存在合法的「坏兽」目标。
		and Duel.IsExistingTarget(c11163040.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只表侧表示的「坏兽」怪兽作为对象。
	local g=Duel.SelectTarget(tp,c11163040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：破坏选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的具体处理：破坏目标坏兽，并从卡组向对应控制者场上特召不同名坏兽。
function c11163040.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local cc=tc:GetControler()
	local code=tc:GetOriginalCodeRule()
	-- 成功破坏目标怪兽后继续执行后续处理。
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查破坏后目标控制者的怪兽区是否有空位。
		if Duel.GetLocationCount(cc,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只原本卡名不同的「坏兽」怪兽。
		local g=Duel.SelectMatchingCard(tp,c11163040.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,cc,code)
		if g:GetCount()>0 then
			-- 效果连接中断（破坏与特召视为不同时发生）。
			Duel.BreakEffect()
			-- 将选中的坏兽往目标控制者场上表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,cc,false,false,POS_FACEUP)
		end
	end
end
-- 效果③的发动条件：卡上的坏兽指示物在3个以上。
function c11163040.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)>=3
end
-- 效果③的Cost：把这张卡送去墓地。
function c11163040.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为Cost的卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选卡组中同名卡以外的「坏兽」魔法·陷阱卡。
function c11163040.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(11163040) and c:IsAbleToHand()
end
-- 效果③的目标确认与操作信息设定。
function c11163040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的同名卡以外的「坏兽」魔陷。
	if chk==0 then return Duel.IsExistingMatchingCard(c11163040.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的具体处理：从卡组把1张「坏兽」魔法·陷阱卡加入手牌。
function c11163040.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「坏兽」魔陷。
	local g=Duel.SelectMatchingCard(tp,c11163040.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
