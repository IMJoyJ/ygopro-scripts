--千年の十字
-- 效果：
-- ①：选自己的手卡·卡组·场上（表侧表示）5张「被封印」怪兽卡，给双方确认。那之后，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤。除「千年」怪兽卡、原本等级是10星以上的「艾克佐迪亚」怪兽卡外的表侧表示的怪兽卡在自己场上存在的场合，再让那些全部回到卡组。这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
local s,id,o=GetID()
-- 初始化效果，注册卡牌效果，设置为发动时点，包含特殊召唤和送回卡组的分类
function s.initial_effect(c)
	-- 记录该卡与「幻之召唤神 艾克佐迪亚」的关联
	aux.AddCodeList(c,83257450)
	-- ①：选自己的手卡·卡组·场上（表侧表示）5张「被封印」怪兽卡，给双方确认。那之后，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 设置发动费用为无费用，仅用于标记标签
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于筛选自己场上、手牌、卡组中表侧表示的「被封印」怪兽卡
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x40) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 过滤函数，用于筛选可以特殊召唤的「幻之召唤神 艾克佐迪亚」
function s.spfilter(c,e,tp)
	return c:IsCode(83257450)
		-- 判断该卡是否可以特殊召唤且场上存在召唤位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置发动时点的处理函数，检查是否满足发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查玩家是否受到「王家长眠之谷」等效果影响
		return not Duel.IsPlayerAffectedByEffect(tp,4130270)
			-- 检查自己手牌、卡组、场上是否存在至少5张「被封印」怪兽卡
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,nil)
			-- 检查自己额外卡组是否存在至少1只「幻之召唤神 艾克佐迪亚」
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	-- 设置发动时点的操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数，用于筛选自己场上表侧表示的怪兽卡，排除等级10星以上或「千年」怪兽卡
function s.dfilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and not (c:GetOriginalLevel()>=10 and c:IsSetCard(0xde) or c:IsSetCard(0x1ae))
end
-- 过滤函数，用于筛选可以送回卡组的怪兽卡
function s.tdfilter(c)
	return s.dfilter(c) and c:IsAbleToDeck()
end
-- 过滤函数，用于筛选不能送回卡组的怪兽卡
function s.ndfilter(c)
	return s.dfilter(c) and not c:IsAbleToDeck()
end
-- 发动效果处理函数，执行选择确认、特殊召唤、送回卡组、设置回合限制等操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否存在满足条件的「被封印」怪兽卡
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,nil) then
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择满足条件的5张「被封印」怪兽卡
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,5,nil,e,tp)
		-- 向玩家确认选择的卡
		Duel.ConfirmCards(tp,g)
		-- 向对方玩家确认选择的卡
		Duel.ConfirmCards(1-tp,g)
		if g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>=1 then
			-- 若选择的卡中包含手牌，则洗切手牌
			Duel.ShuffleHand(tp)
		end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只「幻之召唤神 艾克佐迪亚」
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		-- 将选择的卡特殊召唤到场上
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 获取需要送回卡组的怪兽卡
			local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,0,nil)
			if #tg>0 then
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 将满足条件的怪兽卡送回卡组
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	-- ①：除「千年」怪兽卡、原本等级是10星以上的「艾克佐迪亚」怪兽卡外的表侧表示的怪兽卡在自己场上存在的场合，再让那些全部回到卡组。这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能召唤的限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 注册不能反转召唤的限制效果
	Duel.RegisterEffect(e3,tp)
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将发动的卡送回卡组
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
