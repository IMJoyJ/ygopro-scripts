--速攻召喚
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：进行1只怪兽的通常召唤。那个时候，若对方场上有怪兽存在，5星以上的怪兽召唤的场合需要的解放可以不用。
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外才能发动。把1只可以通常召唤的5星以上的怪兽从自己的卡组·墓地加入手卡。那之后，进行那1只怪兽的上级召唤。
local s,id,o=GetID()
-- 注册3个效果：e1为①效果的魔陷发动型效果（进行1只怪兽的通常召唤），e2为不用解放作通常召唤的召唤规则效果（作为e1的标签对象），e3为②效果（墓地发动的检索+上级召唤，1回合1次）
function s.initial_effect(c)
	-- ①：进行1只怪兽的通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 那个时候，若对方场上有怪兽存在，5星以上的怪兽召唤的场合需要的解放可以不用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(0xff)
	e2:SetCondition(s.ntcon)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	-- 设定发动条件：这张卡送去墓地的回合不能发动这个效果（除非被回手后再送墓）
	e3:SetCondition(aux.exccon)
	-- 设定发动代价：作为cost把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- e2（不用解放召唤）的适用条件：召唤不需要解放（minc为0）、无需祭品即可召唤、该怪兽在手卡，且自己主要怪兽区有空位
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 确认此次召唤所需解放数为0（有0个可用祭品），且该怪兽位于手卡
	return minc==0 and Duel.CheckTribute(c,0) and c:IsLocation(LOCATION_HAND)
		-- 确认自己主要怪兽区至少有1个空位可以放置召唤的怪兽
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 可召唤怪兽的过滤条件：可以正常进行通常召唤或盖放的怪兽，或者对方场上有怪兽时、5星以上且可以适用「不用解放」进行召唤的怪兽
function s.sumfilter(c,res,se)
	return (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
		or (res and c:IsLevelAbove(5) and c:IsSummonable(true,se))
end
-- ①效果的目标判定：确认对方场上是否有怪兽、取得e2召唤规则效果，检查手卡·场上是否存在可召唤的怪兽，并设置含召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽（作为能否适用「不用解放作召唤」的标记res）
	local res=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local se=e:GetLabelObject()
	-- 发动可行性检查：自己的手卡或怪兽区是否至少有1只满足召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,res,se) end
	-- 设置操作信息：预计进行1只怪兽的通常召唤（具体卡在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①效果的处理：从手卡·场上选1只可召唤的怪兽；若对方场上有怪兽、该怪兽为5星以上且可适用不用解放的召唤（必要时询问玩家），则适用e2效果；之后若能表侧召唤则进行通常召唤，否则盖放
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在怪兽（决定是否可适用不用解放的召唤）
	local res=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local se=e:GetLabelObject()
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从自己的手卡·怪兽区选1只可以通常召唤（或可适用不用解放召唤）的怪兽
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,res,se)
	local tc=g:GetFirst()
	if tc then
		local ne=nil
		if (res and tc:IsLevelAbove(5) and tc:IsSummonable(true,se)
			and (not (tc:IsSummonable(true,nil) or tc:IsMSetable(true,nil))
				-- 若该5星以上怪兽原本也能正常召唤，询问玩家是否适用「速攻召唤」的效果不用解放作召唤
				or Duel.SelectYesNo(tp,aux.Stringid(id,2)))) then  --"是否适用「速攻召唤」的效果不用解放作召唤？"
			ne=se
		end
		if tc:IsSummonable(true,ne) and
			(ne==se
				or not tc:IsMSetable(true,ne)
				-- 若该怪兽不能盖放，或玩家选择了表侧攻击表示，则进入召唤处理
				or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 对所选怪兽进行通常召唤（忽略每回合1次的召唤次数限制，适用e2时不用解放）
			Duel.Summon(tp,tc,true,ne)
		-- 否则将该怪兽以里侧守备表示盖放
		else Duel.MSet(tp,tc,true,ne) end
	end
end
-- 检索候选怪兽的过滤条件：5星以上、可以上级召唤或盖放、可以加入手卡、当前存在可行的召唤方式，且玩家未受「不能上级召唤」类限制
function s.thfilter2(c,e,tp)
	local minc,maxc=c:GetTributeRequirement()
	return c:IsLevelAbove(5) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
		and c:IsSummonableCard() and c:IsAbleToHand() and s.sunthfilter(c,e,tp,minc,maxc)
		-- 确认玩家当前可以上级召唤该怪兽（未受「不能上级召唤」等效果影响）
		and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c)
end
-- 综合检查该怪兽当前是否存在可行的召唤方式：若其需2只解放且场上有「随风旅鸟与未知之风」则临时赋予替换解放的召唤程序，再依次验证解放限制、限制召唤程序、自身召唤程序或常规祭品数量是否满足、是否被禁止召唤，全部通过才返回true
function s.sunthfilter(c,e,tp,minc,maxc)
	local e1=nil
	-- 若该怪兽上级召唤需要2只解放，且自己魔法·陷阱区存在未被无效的「随风旅鸟与未知之风」（可适用其替换解放的效果）
	if s.ottg(e,c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		-- 那之后，进行那1只怪兽的上级召唤。
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
		-- 检查自己场上是否存在满足该解放限制效果条件（可作为解放使用）的怪兽
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
		-- 若没有特殊召唤程序可用，则检查场上是否有足够数量（minc～maxc个）的祭品可用于召唤
		if not Duel.CheckTribute(c,minc,maxc) then return false end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON,c:GetControler()) then
		if e1 then e1:Reset() end
		return false
	end
	if e1 then e1:Reset() end
	return true
end
-- 「随风旅鸟与未知之风」（卡号55521751）存在且未被无效的过滤条件
function s.cfilter(c)
	return c:IsCode(55521751) and not c:IsDisabled()
end
-- 替换解放用己方怪兽的过滤条件：可以送去墓地、不受这个效果影响，且离场后主要怪兽区仍有空位
function s.otfilter(c,e,tp)
	-- 该卡可以送去墓地、不受这个效果影响，且其离场后自己主要怪兽区仍有空位
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.GetMZoneCount(tp,c)>0
end
-- 替换解放用对方卡片的过滤条件：可以送去墓地、不受这个效果影响，且不是已确定离场的卡
function s.otfilter2(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 替换解放召唤程序的适用条件：所需解放数不超过2，且自己场上存在可送墓的怪兽、对方场上存在可送墓的卡
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2
		-- 确认自己场上存在1只可以送去墓地（送墓后怪兽区有空位）的怪兽
		and Duel.IsExistingMatchingCard(s.otfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 确认对方场上存在1张可以送去墓地且不受效果影响的卡
		and Duel.IsExistingMatchingCard(s.otfilter2,tp,0,LOCATION_ONFIELD,1,nil,e)
end
-- 判断该怪兽上级召唤所需解放数恰为2只（最少不超过2且最多至少为2），即可适用「随风旅鸟与未知之风」的替换解放
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 调用解放限制效果的判定函数，检查该怪兽是否满足其解放限制条件
function s.sunthfilter2(c,e,ev)
	return ev(e,c)
end
-- ②效果的目标判定：检查卡组·墓地是否有满足条件的5星以上怪兽，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：卡组或墓地是否至少有1只可以加入手卡并上级召唤的5星以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从卡组·墓地把1张卡加入手卡（具体卡在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理：让玩家从卡组·墓地选1只满足条件的怪兽（经王家长眠之谷过滤）加入手卡并给对方确认，中断处理后若可表侧召唤则进行上级召唤，否则将其盖放（至少使用1个祭品）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组·墓地选1只满足条件且不受王家长眠之谷影响的5星以上怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 确认选到的卡成功以效果加入手卡，且该怪兽当前可以上级召唤
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsSummonable(true,nil) then
		-- 把加入手卡的怪兽给对方观看确认
		Duel.ConfirmCards(1-tp,tc)
		-- 中断效果处理，使之后的上级召唤视为不同时处理（避免错过时点）
		Duel.BreakEffect()
		if tc:IsSummonable(true,nil) and (not tc:IsMSetable(true,nil)
			-- 若该怪兽不能盖放，或玩家选择了表侧攻击表示，则进入上级召唤处理
			or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 进行那1只怪兽的上级召唤（至少使用1个祭品，忽略每回合1次的召唤次数限制）
			Duel.Summon(tp,tc,true,nil,1)
		-- 否则将那1只怪兽以里侧守备表示盖放（至少使用1个祭品）
		else Duel.MSet(tp,tc,true,nil,1) end
	end
end
