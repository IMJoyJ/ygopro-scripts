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
	-- ①：每次从手卡·墓地有「坏兽」怪兽特殊召唤给这张卡放置1个坏兽指示物（最多5个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11163040.counter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽破坏，那之后，原本卡名和破坏的那只怪兽不同的1只「坏兽」怪兽从自己卡组往那个控制者场上特殊召唤。
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
	-- ③：把坏兽指示物是3个以上的这张卡送去墓地才能发动。从卡组把「坏兽的出现记录」以外的1张「坏兽」魔法·陷阱卡加入手卡。
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
-- 过滤函数：筛选「坏兽」卡组的卡中从手卡·墓地特殊召唤的怪兽。
function c11163040.cfilter(c)
	return c:IsSetCard(0xd3) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- 若本次特殊召唤成功事件中有从手卡·墓地特殊召唤的「坏兽」怪兽，给这张卡放置1个坏兽指示物。
function c11163040.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c11163040.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x37,1)
	end
end
-- 过滤函数：筛选场上表侧表示的「坏兽」怪兽，且自己卡组存在原本卡名与其不同、可以特殊召唤到其控制者场上的「坏兽」怪兽。
function c11163040.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd3)
		-- 检查自己卡组是否存在1张原本卡名与目标怪兽不同、可以特殊召唤到其控制者场上的「坏兽」怪兽。
		and Duel.IsExistingMatchingCard(c11163040.chkfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetControler(),c:GetOriginalCodeRule())
end
-- 过滤函数：筛选卡组中原本卡名与目标怪兽不同的「坏兽」怪兽，且不受苏生限制、允许特殊召唤到目标怪兽的控制者场上。
function c11163040.chkfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCodeRule(code) and
		-- 确认该卡没有苏生限制，并且玩家能够以表侧表示形式将其特殊召唤到目标怪兽控制者的场上。
		not c:IsHasEffect(EFFECT_REVIVE_LIMIT) and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,cc,c)
end
-- 过滤函数：筛选卡组中原本卡名与目标怪兽不同、可以被特殊召唤到其控制者场上的「坏兽」怪兽。
function c11163040.spfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,cc)
end
-- 目标函数：检查对象是否在怪兽区域且满足筛选条件，并确认场上存在可选择的「坏兽」怪兽且被破坏后其控制者场上有空位。
function c11163040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11163040.filter(chkc,e,tp) end
	-- 确认自己怪兽区域有可用空格（破坏后有位置特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己怪兽区域是否存在1只满足条件的可作为对象的「坏兽」怪兽。
		and Duel.IsExistingTarget(c11163040.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 或者确认对方怪兽区域有可用空格（破坏后有位置特殊召唤）。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-1
		-- 检查对方怪兽区域是否存在1只满足条件的可作为对象的「坏兽」怪兽。
		and Duel.IsExistingTarget(c11163040.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 向玩家发送「请选择要破坏的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方怪兽区域1只满足条件的「坏兽」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c11163040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：确定要破坏1只作为对象的怪兽（用于对方的连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：预计从卡组特殊召唤1只怪兽（用于对方的连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取得对象怪兽，破坏之，然后从其卡组选择1只原本卡名不同的「坏兽」怪兽，特殊召唤到被破坏怪兽的控制者场上。
function c11163040.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁处理的对象卡（被破坏的「坏兽」怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local cc=tc:GetControler()
	local code=tc:GetOriginalCodeRule()
	-- 以效果破坏对象怪兽，若破坏成功才继续处理后续特殊召唤。
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 若被破坏怪兽的控制者场上没有可用怪兽区域空格，则不进行特殊召唤处理。
		if Duel.GetLocationCount(cc,LOCATION_MZONE)<=0 then return end
		-- 向玩家发送「请选择要特殊召唤的卡」的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己卡组选择1只原本卡名与被破坏怪兽不同、可以特殊召唤的「坏兽」怪兽。
		local g=Duel.SelectMatchingCard(tp,c11163040.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,cc,code)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使之后的特殊召唤视为与破坏不同时处理。
			Duel.BreakEffect()
			-- 将选择的「坏兽」怪兽以表侧表示形式特殊召唤到被破坏怪兽的控制者场上。
			Duel.SpecialSummon(g,0,tp,cc,false,false,POS_FACEUP)
		end
	end
end
-- 发动条件：这张卡放置的坏兽指示物是3个以上。
function c11163040.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)>=3
end
-- 代价处理：确认这张卡可以送去墓地作为代价，并将这张卡送去墓地。
function c11163040.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选「坏兽的出现记录」以外的「坏兽」魔法·陷阱卡且可以加入手卡。
function c11163040.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(11163040) and c:IsAbleToHand()
end
-- 目标函数：确认自己卡组存在满足条件的「坏兽」魔法·陷阱卡，并设置加入手卡的操作信息。
function c11163040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在1张满足条件的「坏兽」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11163040.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从自己卡组把1张卡加入手卡（用于对方的连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从自己卡组选择1张「坏兽的出现记录」以外的「坏兽」魔法·陷阱卡加入手卡，并给对方确认。
function c11163040.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送「请选择要加入手牌的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「坏兽」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c11163040.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入自己的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
