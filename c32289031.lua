--星騎士 セイクリッド・デルタテロス
-- 效果：
-- 4星怪兽×3只以上
-- ①：对方不能把自己场上的5阶以上的「星骑士」、「星圣」超量怪兽作为效果的对象。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只「星骑士」、「星圣」怪兽加入手卡。那之后，可以进行1只光属性怪兽的召唤。
-- ③：这张卡从场上以外送去墓地的场合才能发动。自己的手卡·除外状态的1只「星骑士」、「星圣」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果，添加XYZ召唤手续并启用复活限制，注册三个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用4星怪兽3只以上进行叠放
	aux.AddXyzProcedure(c,nil,4,3,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：对方不能把自己场上的5阶以上的「星骑士」、「星圣」超量怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efftg)
	-- 设置效果值为tgoval函数，用于过滤效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只「星骑士」、「星圣」怪兽加入手卡。那之后，可以进行1只光属性怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上以外送去墓地的场合才能发动。自己的手卡·除外状态的1只「星骑士」、「星圣」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果目标过滤函数，筛选5阶以上且为星骑士或星圣的怪兽
function s.efftg(e,c)
	return c:IsSetCard(0x53,0x9c) and c:IsRankAbove(5)
end
-- 效果发动时的费用，消耗1个超量素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索卡牌过滤函数，筛选星骑士或星圣的怪兽
function s.thfilter(c)
	return c:IsSetCard(0x53,0x9c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息，准备从卡组检索1张星骑士或星圣怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否卡组存在满足条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 召唤过滤函数，筛选可通常召唤且为光属性的怪兽
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 检索效果的处理函数，选择卡牌加入手牌并询问是否进行召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡牌加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看手牌
		Duel.ConfirmCards(1-tp,g)
		-- 检查是否有满足条件的光属性怪兽可召唤
		if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择满足条件的卡牌进行召唤
			local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 执行召唤操作
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 特殊召唤效果的发动条件，卡牌从场上以外送去墓地时发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤卡牌过滤函数，筛选星骑士或星圣的怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x53,0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标设置，检查是否有满足条件的卡牌可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的卡牌可特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 特殊召唤效果的处理函数，选择卡牌进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡牌进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
