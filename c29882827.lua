--竜華界闢
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「龙华」怪兽加入手卡。那之后，可以从手卡把1只「龙华」灵摆怪兽表侧加入额外卡组。
-- ②：自己场上有「龙华」灵摆怪兽卡存在的场合，自己主要阶段，从自己墓地把1只「龙华」怪兽和这张卡除外才能发动。原本种族和除外的怪兽相同的1只「龙华」怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：从卡组把1只「龙华」怪兽加入手卡。那之后，可以从手卡把1只「龙华」灵摆怪兽表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索后灵摆卡加入额外卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「龙华」灵摆怪兽卡存在的场合，自己主要阶段，从自己墓地把1只「龙华」怪兽和这张卡除外才能发动。原本种族和除外的怪兽相同的1只「龙华」怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的怪兽卡
function s.thfilter(c)
	return c:IsSetCard(0x1c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否可以检索满足条件的怪兽卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以检索满足条件的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索满足条件的灵摆卡
function s.exfilter(c)
	return c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end
-- 执行①效果的处理流程
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认玩家手牌
		Duel.ConfirmCards(1-tp,g)
		-- 判断玩家手牌中是否存在满足条件的灵摆卡
		if Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_HAND,0,1,nil)
			-- 询问玩家是否将灵摆卡加入额外卡组
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入额外卡组？"
			-- 提示玩家选择要加入额外卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要加入额外卡组的卡"
			-- 选择满足条件的灵摆卡
			local teg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_HAND,0,1,1,nil)
			if teg:GetCount()>0 then
				-- 洗切玩家手牌
				Duel.ShuffleHand(tp)
				-- 中断当前效果
				Duel.BreakEffect()
				-- 将选中的灵摆卡加入额外卡组
				Duel.SendtoExtraP(teg,nil,REASON_EFFECT)
			end
		end
	end
end
-- 判断场上是否存在满足条件的灵摆卡
function s.cofilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1c0)
end
-- 判断是否满足②效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的发动条件
	return Duel.IsExistingMatchingCard(s.cofilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断墓地是否存在满足条件的怪兽卡
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x1c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 判断卡组中是否存在满足条件的怪兽卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalRace())
end
-- 判断卡组中是否存在满足条件的怪兽卡
function s.spfilter(c,e,tp,race)
	return c:IsSetCard(0x1c0) and c:GetOriginalRace()==race
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的发动成本
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 判断是否满足②效果的发动成本
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local race=g:GetFirst():GetOriginalRace()
	g:AddCard(e:GetHandler())
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(100,race)
end
-- 设置②效果的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的处理条件
	if chk==0 then return e:GetLabel()==100 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lab,race=e:GetLabel()
	-- 判断场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,race)
	if #g>0 then
		-- 将选中的怪兽卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
