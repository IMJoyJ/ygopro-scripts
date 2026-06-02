--霊魂鳥神－姫孔雀
-- 效果：
-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3张魔法·陷阱卡回到持有者卡组。那之后，可以从卡组把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c25415052.initial_effect(c)
	-- 记录卡片效果中记载了「灵魂的降神」的卡名
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设定该仪式怪兽不能以仪式召唤以外的方式特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3张魔法·陷阱卡回到持有者卡组。那之后，可以从卡组把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
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
	-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c25415052.retreg)
	c:RegisterEffect(e3)
end
-- ①效果发动的条件检查函数，必须是仪式召唤成功时
function c25415052.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤对方场上可以返回卡组的魔法·陷阱卡片
function c25415052.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 过滤卡组中4星以下且能特殊召唤的灵魂怪兽的过滤函数
function c25415052.spfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果返回卡组发动的检测与效果处理声明
function c25415052.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0的发动检测阶段，检查对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25415052.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置效果分类为返回卡组，预计有至少1张卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
-- 检测卡片是否被送回对应卡组的过滤函数
function c25415052.cfilter(c,p)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(p)
end
-- ①效果的实际处理函数
function c25415052.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c25415052.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()<=0 then return end
	-- 提示玩家选择要回到卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,1,3,nil)
	-- 若选择的卡片成功返回卡组
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取实际被返回卡组的操作卡片组
		local sg2=Duel.GetOperatedGroup()
		-- 若有属于自己的卡片返回自己卡组，洗切自己卡组
		if sg2:IsExists(c25415052.cfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
		-- 若有属于对方的卡片返回对方卡组，洗切对方卡组
		if sg2:IsExists(c25415052.cfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
		if not sg2:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
		-- 获取卡组中所有满足条件的灵魂怪兽
		local tg=Duel.GetMatchingGroup(c25415052.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在灵魂怪兽且自己场上有可用的怪兽区域
		if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且玩家选择从卡组把灵魂怪兽无视召唤条件特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(25415052,1)) then  --"是否从卡组把灵魂怪兽特殊召唤？"
			-- 中断当前效果，使之后的特殊召唤处理与先前的返回卡组处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=tg:Select(tp,1,1,nil)
			-- 将选择的灵魂怪兽无视召唤条件以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 在特殊召唤成功的结束阶段注册灵魂怪兽返回手牌及召唤Token效果的辅助处理函数
function c25415052.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	-- 设置该回合结束阶段强制返回手牌的触发条件
	e1:SetCondition(aux.SpiritReturnConditionForced)
	e1:SetTarget(c25415052.rettg)
	e1:SetOperation(c25415052.retop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 设置该回合结束阶段非强制性（可选）返回手牌的触发条件（用于一些特殊情况）
	e2:SetCondition(aux.SpiritReturnConditionOptional)
	c:RegisterEffect(e2)
end
-- ②效果返回手牌与召唤Token的发动检测与效果处理声明
function c25415052.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
			return true
		else
			-- 检查自己场上是否至少有2个可用的怪兽区域以容纳2只Token
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and not Duel.IsPlayerAffectedByEffect(tp,59822133)
				-- 以及自己是否可以特殊召唤「灵魂鸟衍生物」
				and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND)
		end
	end
	-- 设置效果分类为加入手牌，预计将自身返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	-- 设置效果分类为衍生物，预计产生2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置效果分类为特殊召唤，预计特殊召唤2张卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②效果返回手牌与召唤Token的实际处理函数
function c25415052.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍与效果相关、表侧表示且成功返回手牌
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 且自己场上仍有2个以上的可用怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 且自己依然可以特殊召唤「灵魂鸟衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND) then
		for i=1,2 do
			-- 在自己场上创建「灵魂鸟衍生物」的卡片对象
			local token=Duel.CreateToken(tp,25415053)
			-- 逐步将衍生物特殊召唤至场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成这一批怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
