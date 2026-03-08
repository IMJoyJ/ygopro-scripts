--WW－アイス・ベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只「风魔女」怪兽特殊召唤。这个效果从卡组特殊召唤的怪兽不能解放，这个效果发动的回合，自己不是5星以上的风属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。给与对方500伤害。
function c43722862.initial_effect(c)
	-- 效果原文：①：自己场上没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只「风魔女」怪兽特殊召唤。这个效果从卡组特殊召唤的怪兽不能解放，这个效果发动的回合，自己不是5星以上的风属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43722862,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43722862)
	e1:SetCondition(c43722862.spcon)
	e1:SetCost(c43722862.spcost)
	e1:SetTarget(c43722862.sptg)
	e1:SetOperation(c43722862.spop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡召唤·特殊召唤成功的场合才能发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43722862,2))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,43722863)
	e2:SetTarget(c43722862.damtg)
	e2:SetOperation(c43722862.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录玩家在本回合中特殊召唤的次数，以限制效果①②的使用次数。
	Duel.AddCustomActivityCounter(43722862,ACTIVITY_SPSUMMON,c43722862.counterfilter)
end
-- 计数器过滤函数，判断是否为从额外卡组特殊召唤且等级不低于5星且为风属性的怪兽，否则不能被计入特殊召唤次数。
function c43722862.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND))
end
-- 效果①的发动条件：自己场上没有怪兽存在。
function c43722862.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽存在。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果①的费用：检查本回合是否已经使用过该效果。
function c43722862.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在本回合中是否已经使用过特殊召唤效果。
	if chk==0 then return Duel.GetCustomActivityCount(43722862,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个场地方效果，使对方不能特殊召唤等级低于5星且属性不是风的额外卡组怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43722862.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家场上。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的函数，禁止从额外卡组召唤等级低于5星或属性不是风的怪兽。
function c43722862.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND)) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的目标设定函数，检查是否可以将此卡特殊召唤。
function c43722862.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于筛选卡组中可以特殊召唤的「风魔女」怪兽。
function c43722862.spfilter(c,e,tp)
	return c:IsSetCard(0xf0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理函数，执行特殊召唤并可能从卡组特殊召唤额外怪兽。
function c43722862.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查场上是否还有空位，若无则不继续处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取卡组中所有符合条件的「风魔女」怪兽。
		local g=Duel.GetMatchingGroup(c43722862.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断是否有符合条件的怪兽且玩家选择是否发动。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(43722862,1)) then  --"是否从卡组把1只「风魔女」怪兽特殊召唤？"
			-- 中断当前连锁效果，使后续处理视为不同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				-- 将选择的怪兽特殊召唤到场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				-- 效果原文：这个效果从卡组特殊召唤的怪兽不能解放。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 效果原文：这个效果发动的回合，自己不是5星以上的风属性怪兽不能从额外卡组特殊召唤。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				e2:SetValue(1)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end
-- 效果②的目标设定函数，设置伤害目标和数值。
function c43722862.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为500。
	Duel.SetTargetParam(500)
	-- 设置效果处理时的操作信息，表示将对对方造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果②的处理函数，执行对对方造成500点伤害。
function c43722862.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
