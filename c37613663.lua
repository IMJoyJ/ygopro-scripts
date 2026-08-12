--千年の十字
-- 效果：
-- ①：选自己的手卡·卡组·场上（表侧表示）5张「被封印」怪兽卡，给双方确认。那之后，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤。除「千年」怪兽卡、原本等级是10星以上的「艾克佐迪亚」怪兽卡外的表侧表示的怪兽卡在自己场上存在的场合，再让那些全部回到卡组。这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
local s,id,o=GetID()
-- 初始化函数：创建并注册这张卡的①效果，类型为魔陷发动、自由时点，效果分类包含特殊召唤与回卡组，并设定代价、目标与处理函数。
function s.initial_effect(c)
	-- 记录这张卡上记载着「幻之召唤神 艾克佐迪亚」（卡号83257450）的卡名。
	aux.AddCodeList(c,83257450)
	-- ①：选自己的手卡·卡组·场上（表侧表示）5张「被封印」怪兽卡，给双方确认。那之后，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤。除「千年」怪兽卡、原本等级是10星以上的「艾克佐迪亚」怪兽卡外的表侧表示的怪兽卡在自己场上存在的场合，再让那些全部回到卡组。这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 代价函数：设置标签1标记本效果可以发动（供目标函数区分发动时检查），并直接允许支付代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤器：筛选表侧表示的「被封印」系列（0x40）怪兽卡，用于从自己手卡·卡组·场上选出5张。
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x40) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 过滤器：筛选额外卡组中卡号为83257450的「幻之召唤神 艾克佐迪亚」，且该卡可以被特殊召唤并有可用出场空格。
function s.spfilter(c,e,tp)
	return c:IsCode(83257450)
		-- 检查该卡满足特殊召唤条件，且自己场上存在能让额外卡组怪兽出场的空格。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 目标函数：发动时检查标签未被消耗、未受「G·B·猎人」效果影响、自己手卡·卡组·场上有5张「被封印」怪兽卡且额外卡组有可特殊召唤的「幻之召唤神 艾克佐迪亚」，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 确认自己没有受到卡号4130270「G·B·猎人」的效果影响（场上卡不能回卡组时本卡不能发动）。
		return not Duel.IsPlayerAffectedByEffect(tp,4130270)
			-- 检查自己的手卡·卡组·场上（表侧表示）存在至少5张「被封印」怪兽卡。
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,nil)
			-- 检查自己的额外卡组存在至少1只可以特殊召唤的「幻之召唤神 艾克佐迪亚」。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	-- 设置操作信息：本连锁处理时将把自己额外卡组的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤器：筛选自己场上表侧表示的怪兽卡中，除「千年」系列（0x1ae）怪兽卡和原本等级10星以上的「艾克佐迪亚」系列（0xde）怪兽卡以外的卡。
function s.dfilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and not (c:GetOriginalLevel()>=10 and c:IsSetCard(0xde) or c:IsSetCard(0x1ae))
end
-- 过滤器：在满足回卡组条件的怪兽卡中，进一步筛选能够回到卡组的卡。
function s.tdfilter(c)
	return s.dfilter(c) and c:IsAbleToDeck()
end
-- 过滤器：在满足回卡组条件的怪兽卡中，筛选不能回到卡组的卡（本脚本中预留未使用）。
function s.ndfilter(c)
	return s.dfilter(c) and not c:IsAbleToDeck()
end
-- 效果处理函数：选5张「被封印」怪兽卡给双方确认，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤，再把其他表侧表示怪兽卡全部回卡组，然后适用本回合召唤·反转召唤·特殊召唤限制，最后把这张卡回卡组。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认自己的手卡·卡组·场上仍存在至少5张「被封印」怪兽卡。
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,nil) then
		-- 向自己发出选择提示「请选择给对方确认的卡」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让自己从手卡·卡组·场上（表侧表示）选出5张「被封印」怪兽卡。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,5,nil,e,tp)
		-- 把选出的5张卡给自己确认。
		Duel.ConfirmCards(tp,g)
		-- 把选出的5张卡给对方确认。
		Duel.ConfirmCards(1-tp,g)
		if g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>=1 then
			-- 若选出的卡中包含手卡，则洗切自己的手卡。
			Duel.ShuffleHand(tp)
		end
		-- 向自己发出选择提示「请选择要特殊召唤的卡」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让自己从额外卡组选出1只可以特殊召唤的「幻之召唤神 艾克佐迪亚」。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		-- 若成功选出该卡，则将其以表侧表示特殊召唤到自己场上，成功时继续后续处理。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 检索自己场上除「千年」怪兽卡、原本等级10星以上的「艾克佐迪亚」怪兽卡外的表侧表示且能回卡组的怪兽卡。
			local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,0,nil)
			if #tg>0 then
				-- 中断当前效果处理，使回卡组处理与特殊召唤视为不同时进行（错时点）。
				Duel.BreakEffect()
				-- 把那些表侧表示的怪兽卡全部回到卡组并洗切卡组。
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	-- 这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「这个回合自己不能召唤怪兽」的效果注册给自己，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 把「这个回合自己不能特殊召唤怪兽」的效果注册给自己，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 把「这个回合自己不能反转召唤怪兽」的效果注册给自己，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 中断当前效果处理，使这张卡回卡组与之前的处理视为不同时进行。
		Duel.BreakEffect()
		-- 发动后这张卡不送去墓地，回到卡组并洗切卡组。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
