--真竜の目覚め
-- 效果：
-- ①：「龙魔王」怪兽以及除灵摆怪兽以外的「龙剑士」怪兽在场上存在的场合才能发动。双方场上的卡全部回到持有者卡组。那之后，可以从卡组把1只「龙剑士」怪兽或者「龙魔王」怪兽无视召唤条件特殊召唤。
function c87765315.initial_effect(c)
	-- ①：「龙魔王」怪兽以及除灵摆怪兽以外的「龙剑士」怪兽在场上存在的场合才能发动。双方场上的卡全部回到持有者卡组。那之后，可以从卡组把1只「龙剑士」怪兽或者「龙魔王」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c87765315.condition)
	e1:SetTarget(c87765315.target)
	e1:SetOperation(c87765315.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「龙魔王」怪兽
function c87765315.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xda)
end
-- 过滤条件：场上表侧表示的除灵摆怪兽以外的「龙剑士」怪兽
function c87765315.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xc7) and not c:IsType(TYPE_PENDULUM)
end
-- 过滤条件：卡组中可以特殊召唤的「龙剑士」怪兽或「龙魔王」怪兽
function c87765315.filter3(c,e,tp)
	return c:IsSetCard(0xda,0xc7) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动条件：场上同时存在「龙魔王」怪兽以及除灵摆怪兽以外的「龙剑士」怪兽
function c87765315.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的「龙魔王」怪兽
	return Duel.IsExistingMatchingCard(c87765315.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且检查双方场上是否存在至少1只表侧表示的除灵摆怪兽以外的「龙剑士」怪兽
		and Duel.IsExistingMatchingCard(c87765315.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果发动时的目标选择与操作信息注册
function c87765315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上所有可以回到卡组的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将场上所有可以回到卡组的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将场上的卡全部回到持有者卡组，之后可以从卡组无视召唤条件特殊召唤1只「龙剑士」或「龙魔王」怪兽
function c87765315.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有可以回到卡组的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些卡全部回到持有者卡组并洗牌，若成功让至少1张卡回到卡组
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 且自身场上有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在可以特殊召唤的「龙剑士」或「龙魔王」怪兽
		and Duel.IsExistingMatchingCard(c87765315.filter3,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 且玩家选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(87765315,0)) then  --"是否要把怪兽特殊召唤？"
		-- 中断当前效果，使后续的特殊召唤处理与回到卡组不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的「龙剑士」或「龙魔王」怪兽
		local g=Duel.SelectMatchingCard(tp,c87765315.filter3,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤到自身场上
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
