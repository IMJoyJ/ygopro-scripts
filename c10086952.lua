--速攻召喚
local s,id,o=GetID()
-- 注册卡片的基本效果（包含速攻魔法发动效果、通常召唤规则改写效果以及墓地发动效果）。
function s.initial_effect(c)
	-- ● 效果①：卡的发动
①：主要阶段及对方怪兽检查时可以发动。进行1只怪兽的通常召唤（表侧攻击表示或里侧守备表示）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ● 规则/协助效果：无解放通常召唤前置
配合卡片效果实现特定的通常召唤（无需解放怪兽）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(0xff)
	e2:SetCondition(s.ntcon)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	-- ● 效果②：墓地发动
这个卡名的②效果1回合只能使用1次。
②：把墓地的这张卡除外才能发动。从卡组·墓地把1只等级5以上的怪兽加入手牌。那之后，可以把1只怪兽通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	-- 限制此效果不能在送入墓地的回合发动。
	e3:SetCondition(aux.exccon)
	-- Cost：把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 判断是否满足无需解放召唤的条件（需在手牌且场上有怪兽区域空位）。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查所需解放数是否为0，且卡片在手牌中。
	return minc==0 and Duel.CheckTribute(c,0) and c:IsLocation(LOCATION_HAND)
		-- 检查控制者的怪兽区是否有空位数大于0。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检索/筛选可进行通常召唤（或无需解放召唤）的怪兽。
function s.sumfilter(c,res,se)
	return (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
		or (res and c:IsLevelAbove(5) and c:IsSummonable(true,se))
end
-- 发动效果①时的目标确认与处理信息设定。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽。
	local res=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local se=e:GetLabelObject()
	-- 发动条件检查：手牌或场上是否有可以通常召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,res,se) end
	-- 设置操作信息：包含通常召唤分类。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 发动效果①的具体处理：选择1只怪兽进行通常召唤（表侧攻击表示或里侧守备表示）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在怪兽。
	local res=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local se=e:GetLabelObject()
	-- 提示玩家选择要召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家选择1只可以通常召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,res,se)
	local tc=g:GetFirst()
	if tc then
		local ne=nil
		if (res and tc:IsLevelAbove(5) and tc:IsSummonable(true,se)
			and (not (tc:IsSummonable(true,nil) or tc:IsMSetable(true,nil))
				-- 询问玩家是否使用无需解放的通常召唤方式。
				or Duel.SelectYesNo(tp,aux.Stringid(id,2)))) then
			ne=se
		end
		if tc:IsSummonable(true,ne) and
			(ne==se
				or not tc:IsMSetable(true,ne)
				-- 询问并确认选择表侧攻击表示还是里侧守备表示。
				or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 执行表侧攻击表示通常召唤。
			Duel.Summon(tp,tc,true,ne)
		-- 执行里侧守备表示放置（MSet）。
		else Duel.MSet(tp,tc,true,ne) end
	end
end
-- 筛选可加入手牌并能进行通常召唤的等级5以上怪兽。
function s.thfilter2(c,e,tp)
	local minc,maxc=c:GetTributeRequirement()
	return c:IsLevelAbove(5) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
		and c:IsSummonableCard() and c:IsAbleToHand() and s.sunthfilter(c,e,tp,minc,maxc)
		-- 确认玩家是否具备解放召唤该怪兽的资格。
		and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c)
end
-- 辅助过滤：检查怪兽在特定环境/规则下是否允许召唤或解放召唤。
function s.sunthfilter(c,e,tp,minc,maxc)
	local e1=nil
	-- 检查是否满足特定永续魔法/陷阱卡协助下的特殊解放召唤条件。
	if s.ottg(e,c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		-- ● 临时规则效果：为符合条件的怪兽注册解放召唤手续
在检索判定过程中，为怪兽临时赋予特定解放召唤手续并进行合法性校验。
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
		-- 检查是否存在满足祭品限制要求的怪兽。
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
		-- 检查场上怪兽数量是否满足该怪兽解放召唤需要的祭品数量。
		if not Duel.CheckTribute(c,minc,maxc) then return false end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON,c:GetControler()) then
		if e1 then e1:Reset() end
		return false
	end
	if e1 then e1:Reset() end
	return true
end
-- 检查魔法陷阱区是否存在未被无效的指定卡片（如帝王的烈旋）。
function s.cfilter(c)
	return c:IsCode(55521751) and not c:IsDisabled()
end
-- 筛选自己场上可以送去墓地作为解放祭品的怪兽。
function s.otfilter(c,e,tp)
	-- 条件：可送去墓地、不受效果免疫且能留出怪兽区空位。
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选对方场上可以送去墓地的卡。
function s.otfilter2(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 检查使用替代解放条件时，双方场上是否有合法用于送去墓地的卡。
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2
		-- 检查自己场上是否存在可用于替代解放送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(s.otfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上是否存在可用于替代解放送去墓地的卡。
		and Duel.IsExistingMatchingCard(s.otfilter2,tp,0,LOCATION_ONFIELD,1,nil,e)
end
-- 判断怪兽的祭品需求是否在1~2只之间。
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 评估祭品限制效果的条件函数。
function s.sunthfilter2(c,e,ev)
	return ev(e,c)
end
-- 墓地效果②的目标确认与操作信息设定。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组或墓地是否存在符合条件的5星以上怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组/墓地把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 墓地效果②的具体处理：把怪兽加入手牌，之后可选择进行通常召唤/放置。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组/墓地选择1只符合条件的怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽加入手牌，并检查其是否可以通常召唤。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsSummonable(true,nil) then
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 效果连接中断（前后步骤视为不同时发生）。
		Duel.BreakEffect()
		if tc:IsSummonable(true,nil) and (not tc:IsMSetable(true,nil)
			-- 选择通常召唤（攻击表示）还是放置（守备表示）。
			or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 执行表侧攻击表示的通常召唤。
			Duel.Summon(tp,tc,true,nil,1)
		-- 执行里侧守备表示的放置（MSet）。
		else Duel.MSet(tp,tc,true,nil,1) end
	end
end
