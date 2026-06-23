--ユニオン・アクティベーション
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：机械族·光属性的1只通常怪兽或同盟怪兽从手卡·卡组送去墓地，和那只怪兽是攻击力相同而原本卡名不同的1只机械族·光属性怪兽从卡组加入手卡。
-- ②：这张卡在墓地存在的状态，自己把机械族·光属性怪兽3只同时特殊召唤的场合，把这张卡除外才能发动。从卡组把1只攻击力3000以上的怪兽加入手卡。那之后，进行那1只怪兽的召唤。
local s,id,o=GetID()
-- 注册两个效果：①效果和②效果
function s.initial_effect(c)
	-- ①：机械族·光属性的1只通常怪兽或同盟怪兽从手卡·卡组送去墓地，和那只怪兽是攻击力相同而原本卡名不同的1只机械族·光属性怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己把机械族·光属性怪兽3只同时特殊召唤的场合，把这张卡除外才能发动。从卡组把1只攻击力3000以上的怪兽加入手卡。那之后，进行那1只怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡并召唤"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	-- 效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION
-- 过滤函数：选择满足条件的怪兽（通常怪兽或同盟怪兽，光属性，机械族，可送去墓地，并且卡组中存在满足条件的另一张卡）
function s.tgfilter(c,tp)
	return c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
		-- 检查卡组中是否存在满足条件的另一张卡（不同卡号但攻击力相同）
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetOriginalCodeRule(),c:GetAttack())
end
-- 过滤函数：选择满足条件的怪兽（非原卡号，光属性，机械族，攻击力相同）
function s.thfilter(c,code,atk)
	return not c:IsOriginalCodeRule(code) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAttack(atk) and c:IsAbleToHand()
end
-- 效果①的发动时处理，设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件（手卡或卡组中存在满足条件的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽（手卡或卡组）
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽送去墓地并判断是否成功
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的怪兽（卡组）
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetOriginalCodeRule(),tc:GetAttack())
		if sg:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤函数：选择满足条件的怪兽（光属性，机械族，已召唤）
function s.spfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上有3只光属性机械族怪兽特殊召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,3,nil,tp)
end
-- 过滤函数：选择满足条件的怪兽（攻击力3000以上，可召唤，可加入手牌）
function s.thfilter2(c,e,tp)
	local minc,maxc=c:GetTributeRequirement()
	-- 检查怪兽是否满足召唤条件（攻击力3000以上，可召唤，可加入手牌）
	return c:IsAttackAbove(3000) and c:IsSummonable(true,nil) and c:IsSummonableCard() and c:IsAbleToHand() and s.sunthfilter(c,e,tp,minc,maxc) and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c)
end
-- 召唤条件检查函数
function s.sunthfilter(c,e,tp,minc,maxc)
	local e1=nil
	-- 检查是否满足召唤条件（有特定魔法卡在场）
	if s.ottg(e,c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		-- 创建召唤效果并注册
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
		-- 检查是否满足召唤条件（是否有满足条件的祭品）
		if not Duel.IsExistingMatchingCard(s.sunthfilter2,tp,LOCATION_MZONE,0,1,nil,e,ev) then
			return false
		end
	end
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC,c:GetControler()) then
		local tte=c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC,c:GetControler())
		local ec=tte:GetCondition()
		if not ec(e,c,0) then return false end
	end
	if c:IsHasEffect(EFFECT_SUMMON_PROC,c:GetControler()) then
		local tte=c:IsHasEffect(EFFECT_SUMMON_PROC,c:GetControler())
		local ec=tte:GetCondition()
		if ec(e,c,0) then
			return true
		end
	else
		-- 检查是否满足召唤条件（是否有足够的祭品）
		if not Duel.CheckTribute(c,minc,maxc) then return false end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON,c:GetControler()) then
		return false
	end
	if e1 then e1:Reset() end
	return true
end
-- 过滤函数：检查是否有特定魔法卡在场
function s.cfilter(c)
	return c:IsCode(55521751) and not c:IsDisabled()
end
-- 过滤函数：检查是否可以送去墓地
function s.otfilter(c,e,tp)
	-- 检查是否可以送去墓地（不免疫效果且场上怪兽区有空位）
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数：检查是否可以送去墓地（不免疫效果且未确认离开）
function s.otfilter2(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 召唤条件函数
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2
		-- 检查场上是否有满足条件的怪兽（可送去墓地）
		and Duel.IsExistingMatchingCard(s.otfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查对方场上是否有满足条件的卡（可送去墓地）
		and Duel.IsExistingMatchingCard(s.otfilter2,tp,0,LOCATION_ONFIELD,1,nil,e)
end
-- 获取怪兽的祭品要求
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 检查是否满足召唤条件（祭品要求）
function s.sunthfilter2(c,e,ev)
	return ev(e,c)
end
-- 效果②的发动时处理，设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件（卡组中存在满足条件的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽（卡组）
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽加入手牌并判断是否可召唤
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsSummonable(true,nil) then
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
