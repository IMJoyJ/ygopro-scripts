--トイポット
-- 效果：
-- ①：1回合1次，丢弃1张手卡才能发动。自己从卡组抽1张，给双方确认。确认的卡是「毛绒动物」怪兽的场合，可以从手卡把1只怪兽特殊召唤。不是的场合，那张抽到的卡丢弃。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物」怪兽加入手卡。
function c70245411.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，丢弃1张手卡才能发动。自己从卡组抽1张，给双方确认。确认的卡是「毛绒动物」怪兽的场合，可以从手卡把1只怪兽特殊召唤。不是的场合，那张抽到的卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70245411,0))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c70245411.spcost)
	e2:SetTarget(c70245411.sptg)
	e2:SetOperation(c70245411.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70245411,1))  --"卡组1只怪兽加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c70245411.thtg)
	e3:SetOperation(c70245411.thop)
	c:RegisterEffect(e3)
end
-- ①号效果的Cost（发动费用）函数：丢弃1张手卡
function c70245411.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0（检查是否可行）时，判断手卡中是否存在除这张卡以外可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ①号效果的Target（发动准备/检查）函数：检查是否能抽卡并设置抽卡操作信息
function c70245411.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，判断玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤函数：判断卡片是否可以被特殊召唤
function c70245411.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的Operation（效果处理）函数：抽卡、确认，并根据卡片种类决定特殊召唤或丢弃
function c70245411.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家因效果抽1张卡，若未能成功抽卡则结束处理
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取刚才因抽卡操作实际加入手牌的那张卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡给对方玩家确认
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsSetCard(0xa9) and tc:IsType(TYPE_MONSTER) then
		-- 判断自己场上是否有可用的怪兽区域，若没有则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取自己手卡中所有可以特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(c70245411.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若手卡有可特召的怪兽，则询问玩家是否进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(70245411,2)) then  --"是否特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理与抽卡不视为同时处理（会造成错时点）
			Duel.BreakEffect()
			-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 将选择的怪兽以表侧表示特殊召唤到自己的场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 中断当前效果，使后续的丢弃处理与抽卡不视为同时处理（会造成错时点）
		Duel.BreakEffect()
		-- 将那张抽到的卡因效果丢弃送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
	end
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 过滤函数：判断卡片是否为「锋利小鬼·剪刀」或「毛绒动物」怪兽，且能加入手卡
function c70245411.filter(c)
	return (c:IsCode(30068120) or (c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER))) and c:IsAbleToHand()
end
-- ②号效果的Target（发动准备/检查）函数：检查卡组中是否存在可检索的卡并设置检索操作信息
function c70245411.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70245411.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的Operation（效果处理）函数：从卡组选择满足条件的卡加入手卡并确认
function c70245411.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c70245411.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
