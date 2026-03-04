--壊獣の出現記録
-- 效果：
-- ①：每次从手卡·墓地有「坏兽」怪兽特殊召唤给这张卡放置1个坏兽指示物（最多5个）。
-- ②：1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽破坏，那之后，原本卡名和破坏的那只怪兽不同的1只「坏兽」怪兽从自己卡组往那个控制者场上特殊召唤。
-- ③：把坏兽指示物是3个以上的这张卡送去墓地才能发动。从卡组把「坏兽的出现记录」以外的1张「坏兽」魔法·陷阱卡加入手卡。
function c11163040.initial_effect(c)
	c:EnableCounterPermit(0x37)
	c:SetCounterLimit(0x37,5)
	-- ①：每次从手卡·墓地有「坏兽」怪兽特殊召唤给这张卡放置1个坏兽指示物（最多5个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽破坏，那之后，原本卡名和破坏的那只怪兽不同的1只「坏兽」怪兽从自己卡组往那个控制者场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11163040.counter)
	c:RegisterEffect(e2)
	-- ③：把坏兽指示物是3个以上的这张卡送去墓地才能发动。从卡组把「坏兽的出现记录」以外的1张「坏兽」魔法·陷阱卡加入手卡。
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
	-- 效果作用
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
-- 过滤函数，用于判断怪兽是否为坏兽且来自手卡或墓地
function c11163040.cfilter(c)
	return c:IsSetCard(0xd3) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- 当有怪兽特殊召唤成功时，若该怪兽为坏兽则给此卡放置1个坏兽指示物
function c11163040.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c11163040.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x37,1)
	end
end
-- 过滤函数，用于判断场上是否可以破坏的坏兽怪兽
function c11163040.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd3)
		-- 检查是否在卡组中存在满足条件的坏兽魔法/陷阱卡
		and Duel.IsExistingMatchingCard(c11163040.chkfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetControler(),c:GetOriginalCodeRule())
end
-- 过滤函数，用于判断卡组中是否可以特殊召唤的坏兽怪兽
function c11163040.chkfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCodeRule(code) and
		-- 检查该怪兽是否具有复活限制且当前玩家能否特殊召唤该怪兽
		not c:IsHasEffect(EFFECT_REVIVE_LIMIT) and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,cc,c)
end
-- 过滤函数，用于选择可以特殊召唤的坏兽怪兽
function c11163040.spfilter(c,e,tp,cc,code)
	return c:IsSetCard(0xd3) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,cc)
end
-- 设置效果目标选择函数
function c11163040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11163040.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：自己或对方场上有坏兽怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己场上是否存在满足条件的坏兽怪兽
		and Duel.IsExistingTarget(c11163040.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上是否存在满足条件的坏兽怪兽
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-1
		-- 检查对方场上是否存在满足条件的坏兽怪兽
		and Duel.IsExistingTarget(c11163040.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c11163040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 设置效果处理函数
function c11163040.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local cc=tc:GetControler()
	local code=tc:GetOriginalCodeRule()
	-- 破坏目标怪兽
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查目标怪兽控制者场上是否有空位
		if Duel.GetLocationCount(cc,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 从卡组中选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c11163040.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,cc,code)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,cc,false,false,POS_FACEUP)
		end
	end
end
-- 判断效果发动条件：坏兽指示物数量是否达到3个
function c11163040.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)>=3
end
-- 设置效果发动费用：将此卡送去墓地
function c11163040.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于检索卡组中的坏兽魔法/陷阱卡
function c11163040.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(11163040) and c:IsAbleToHand()
end
-- 设置效果目标选择函数
function c11163040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的坏兽魔法/陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11163040.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果处理函数
function c11163040.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c11163040.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
