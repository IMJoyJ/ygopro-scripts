--速攻召喚
local s,id,o=GetID()
-- 初始化效果，创建并注册3个效果：e1为通常召唤+盖放怪兽的发动效果，e2为通常召唤规则效果，e3为墓地发动的效果。
function s.initial_effect(c)
	-- 效果1：通常召唤+盖放怪兽的发动效果，自由时点，可选择召唤或盖放怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果2：通常召唤规则效果，允许玩家在场上没有怪兽区时进行通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(0xff)
	e2:SetCondition(s.ntcon)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	-- 效果3：墓地发动的效果，可以检索并特殊召唤满足条件的怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	-- 效果3的发动条件为：这张卡送去墓地的回合不能发动此效果。
	e3:SetCondition(aux.exccon)
	-- 效果3的发动费用为：把这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 通常召唤规则函数，判断是否可以进行通常召唤。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足通常召唤条件：祭品数量为0且手牌中有怪兽。
	return minc==0 and Duel.CheckTribute(c,0) and c:IsLocation(LOCATION_HAND)
		-- 判断是否满足通常召唤条件：场上存在可用怪兽区。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤过滤函数，判断是否可以通常召唤或盖放。
function s.sumfilter(c,res,se)
	return (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
		or (res and c:IsLevelAbove(5) and c:IsSummonable(true,se))
end
-- 目标选择函数，判断是否可以发动效果。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在怪兽。
	local res=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local se=e:GetLabelObject()
	-- 检查是否有满足召唤条件的卡牌。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,res,se) end
	-- 设置操作信息为召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 发动函数，选择并执行召唤或盖放。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在怪兽。
	local res=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local se=e:GetLabelObject()
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足召唤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,res,se)
	local tc=g:GetFirst()
	if tc then
		local ne=nil
		if (res and tc:IsLevelAbove(5) and tc:IsSummonable(true,se)
			and (not (tc:IsSummonable(true,nil) or tc:IsMSetable(true,nil))
				-- 如果满足条件且等级大于等于5，则使用特殊召唤规则。
				or Duel.SelectYesNo(tp,aux.Stringid(id,2)))) then
			ne=se
		end
		if tc:IsSummonable(true,ne) and
			(ne==se
				or not tc:IsMSetable(true,ne)
				-- 如果召唤失败则选择攻击表示。
				or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 执行通常召唤。
			Duel.Summon(tp,tc,true,ne)
		-- 执行盖放。
		else Duel.MSet(tp,tc,true,ne) end
	end
end
-- 检索过滤函数，判断是否可以检索并特殊召唤。
function s.thfilter2(c,e,tp)
	local minc,maxc=c:GetTributeRequirement()
	return c:IsLevelAbove(5) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
		and c:IsSummonableCard() and c:IsAbleToHand() and s.sunthfilter(c,e,tp,minc,maxc)
		-- 判断玩家是否可以进行上级召唤。
		and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c)
end
-- 特殊召唤条件检查函数，用于判断是否满足特殊召唤条件。
function s.sunthfilter(c,e,tp,minc,maxc)
	local e1=nil
	-- 如果满足条件且场上存在特定魔法卡，则创建特殊召唤效果。
	if s.ottg(e,c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		-- 特殊召唤条件检查函数的完整实现。
		e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(s.otcon)
		e1:SetValue(SUMMON_TYPE_ADVANCE)
		c:RegisterEffect(e1,true)
	end
	if c:IsHasEffect(EFFECT_TRIBUTE_LIMIT,c:GetControler()) then
		local te=c:IsHasEffect(EFFECT_TRIBUTE_LIMIT,tp)
		local ev=te:GetValue()
		-- 如果不存在满足条件的怪兽则返回false。
		if not Duel.IsExistingMatchingCard(s.sunthfilter2,tp,LOCATION_MZONE,0,1,nil,e,ev) then
			if e1 then e1:Reset() end
			return false
		end
	end
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC,c:GetControler()) then
		local tte=c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC,c:GetControler())
		local ec=tte:GetCondition()
		if not ec(e,c,0) then
			if e1 then e1:Reset() end
			return false
		end
	end
	if c:IsHasEffect(EFFECT_SUMMON_PROC,c:GetControler()) then
		local tte=c:IsHasEffect(EFFECT_SUMMON_PROC,c:GetControler())
		local ec=tte:GetCondition()
		if ec(e,c,0) then
			if e1 then e1:Reset() end
			return true
		end
	else
		-- 检查祭品是否满足要求。
		if not Duel.CheckTribute(c,minc,maxc) then return false end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON,c:GetControler()) then
		if e1 then e1:Reset() end
		return false
	end
	if e1 then e1:Reset() end
	return true
end
-- 过滤函数，判断是否为特定魔法卡。
function s.cfilter(c)
	return c:IsCode(55521751) and not c:IsDisabled()
end
-- 过滤函数，判断是否可以送去墓地且场上存在可用区域。
function s.otfilter(c,e,tp)
	-- 返回可以送去墓地且场上存在可用区域的卡。
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，判断是否可以送去墓地且未确认离开。
function s.otfilter2(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤条件。
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2
		-- 检查场上是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(s.otfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上有无满足条件的卡。
		and Duel.IsExistingMatchingCard(s.otfilter2,tp,0,LOCATION_ONFIELD,1,nil,e)
end
-- 判断祭品数量是否在2以内。
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 用于调用特殊召唤条件函数。
function s.sunthfilter2(c,e,ev)
	return ev(e,c)
end
-- 检索目标选择函数，判断是否可以发动效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足检索条件的卡牌。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索发动函数，选择并执行检索和召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功加入手牌且可以通常召唤，则进行后续处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsSummonable(true,nil) then
		-- 确认对方看到该卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果。
		Duel.BreakEffect()
		if tc:IsSummonable(true,nil) and (not tc:IsMSetable(true,nil)
			-- 如果召唤失败则选择攻击表示。
			or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 执行通常召唤。
			Duel.Summon(tp,tc,true,nil,1)
		-- 执行盖放。
		else Duel.MSet(tp,tc,true,nil,1) end
	end
end
