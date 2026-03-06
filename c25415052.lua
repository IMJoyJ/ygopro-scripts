--霊魂鳥神－姫孔雀
-- 效果：
-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3张魔法·陷阱卡回到持有者卡组。那之后，可以从卡组把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c25415052.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 规则层面操作：设置此卡必须通过仪式召唤才能特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3张魔法·陷阱卡回到持有者卡组。那之后，可以从卡组把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25415052,0))  --"对方魔法·陷阱回到卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c25415052.tdcon)
	e2:SetTarget(c25415052.tdtg)
	e2:SetOperation(c25415052.tdop)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c25415052.retreg)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断此卡是否为仪式召唤 summoned
function c25415052.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 规则层面操作：过滤满足条件的魔法·陷阱卡
function c25415052.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 规则层面操作：过滤满足条件的灵魂怪兽
function c25415052.spfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果原文内容：选对方场上最多3张魔法·陷阱卡回到持有者卡组
function c25415052.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25415052.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面操作：设置连锁操作信息为将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
-- 规则层面操作：过滤满足条件的卡
function c25415052.cfilter(c,p)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(p)
end
-- 规则层面操作：处理效果主要流程，包括选择并送回魔法·陷阱卡，以及可能的特殊召唤灵魂怪兽
function c25415052.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c25415052.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()<=0 then return end
	-- 规则层面操作：提示玩家选择要送回卡组的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,1,3,nil)
	-- 规则层面操作：将选中的卡送回卡组
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 规则层面操作：获取实际被操作的卡组
		local sg2=Duel.GetOperatedGroup()
		-- 规则层面操作：若送回卡组的卡属于玩家，则洗切其卡组
		if sg2:IsExists(c25415052.cfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
		-- 规则层面操作：若送回卡组的卡属于对手，则洗切其卡组
		if sg2:IsExists(c25415052.cfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
		if not sg2:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
		-- 规则层面操作：获取满足条件的灵魂怪兽组
		local tg=Duel.GetMatchingGroup(c25415052.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 规则层面操作：检查是否有灵魂怪兽可特殊召唤且场上存在空位
		if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 规则层面操作：询问玩家是否特殊召唤灵魂怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(25415052,1)) then  --"是否从卡组把灵魂怪兽特殊召唤？"
			-- 规则层面操作：中断当前效果处理
			Duel.BreakEffect()
			-- 规则层面操作：提示玩家选择要特殊召唤的灵魂怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=tg:Select(tp,1,1,nil)
			-- 规则层面操作：将选中的灵魂怪兽无视召唤条件特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 效果原文内容：②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c25415052.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果原文内容：②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	-- 规则层面操作：设置效果触发条件为强制返回手牌
	e1:SetCondition(aux.SpiritReturnConditionForced)
	e1:SetTarget(c25415052.rettg)
	e1:SetOperation(c25415052.retop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 规则层面操作：设置效果触发条件为可选择不返回手牌
	e2:SetCondition(aux.SpiritReturnConditionOptional)
	c:RegisterEffect(e2)
end
-- 效果原文内容：②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c25415052.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
			return true
		else
			-- 规则层面操作：检查玩家场上是否有足够的空位
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and not Duel.IsPlayerAffectedByEffect(tp,59822133)
				-- 规则层面操作：检查玩家是否可以特殊召唤衍生物
				and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND)
		end
	end
	-- 规则层面操作：设置连锁操作信息为将此卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	-- 规则层面操作：设置连锁操作信息为召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 规则层面操作：设置连锁操作信息为特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果原文内容：②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c25415052.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：检查此卡是否有效且处于正面表示状态且已送回手牌
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 规则层面操作：检查玩家场上是否有足够的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面操作：检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND) then
		for i=1,2 do
			-- 规则层面操作：创建衍生物
			local token=Duel.CreateToken(tp,25415053)
			-- 规则层面操作：特殊召唤衍生物
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 规则层面操作：完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
