--霊魂鳥神－姫孔雀
-- 效果：
-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3张魔法·陷阱卡回到持有者卡组。那之后，可以从卡组把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c25415052.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「灵魂的降神」(73055622)的卡名
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤限制为只能通过仪式召唤方式出场
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3张魔法·陷阱卡回到持有者卡组。那之后，可以从卡组把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25415052,0))  --"对方魔法·陷阱回到卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c25415052.tdcon)
	e2:SetTarget(c25415052.tdtg)
	e2:SetOperation(c25415052.tdop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的回合的结束阶段发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c25415052.retreg)
	c:RegisterEffect(e3)
end
-- 效果①的Condition函数：检查这张卡是否通过仪式召唤方式登场
function c25415052.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：筛选场上可返回卡组的魔法卡和陷阱卡
function c25415052.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 过滤函数：筛选卡组中4星以下、灵魂类别且可无视召唤条件特殊召唤的怪兽
function c25415052.spfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的Target函数：检测对方场上是否存在可返回卡组的魔法·陷阱卡，并设置返回卡组的操作信息
function c25415052.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认对方场上存在至少1张可返回卡组的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25415052.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置将卡片返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
-- 过滤函数：检查卡片当前是否位于指定玩家p的卡组中（用于判断是否需要洗切对应玩家的卡组）
function c25415052.cfilter(c,p)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(p)
end
-- 效果①的Operation函数：选对方场上1至3张魔法·陷阱卡洗回卡组，随后可询问玩家从卡组无视召唤条件特召1只4星以下灵魂怪兽
function c25415052.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可返回卡组的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c25415052.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()<=0 then return end
	-- 向己方玩家发送选择要返回卡组的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,1,3,nil)
	-- 以效果将选中的1至3张对方魔法·陷阱卡洗回持有者卡组，并检查是否至少成功操作1张
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取刚刚实际被返回卡组（或额外卡组）的卡片组
		local sg2=Duel.GetOperatedGroup()
		-- 若有己方所属的卡被送回己方卡组，则手动洗切己方卡组
		if sg2:IsExists(c25415052.cfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
		-- 若有对方所属的卡被送回对方卡组，则手动洗切对方卡组
		if sg2:IsExists(c25415052.cfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
		if not sg2:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
		-- 获取己方卡组中所有可无视召唤条件特殊召唤的4星以下灵魂怪兽
		local tg=Duel.GetMatchingGroup(c25415052.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检查卡组中存在可特召的灵魂怪兽且己方主要怪兽区仍有空位
		if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问己方玩家是否要从卡组特殊召唤1只4星以下的灵魂怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(25415052,1)) then  --"是否从卡组把灵魂怪兽特殊召唤？"
			-- 中断当前处理步骤，使后续卡组特召与前面的回卡组处理视为不同时处理（“那之后”）
			Duel.BreakEffect()
			-- 向己方玩家发送选择要特殊召唤的怪兽提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=tg:Select(tp,1,1,nil)
			-- 无视召唤条件将选中的4星以下灵魂怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 效果②的注册辅助函数：在结束阶段分别注册灵魂怪兽强制回手与可选回手（如受效果影响）的两个触发效果，持续到本回合结束阶段
function c25415052.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	-- 设置强制回手分支的条件：检查该怪兽未受到不回手或可选不回手效果影响时必须发动
	e1:SetCondition(aux.SpiritReturnConditionForced)
	e1:SetTarget(c25415052.rettg)
	e1:SetOperation(c25415052.retop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 设置选发回手分支的条件：检查该怪兽拥有“可以不返回手卡”状态时可由玩家选择是否发动
	e2:SetCondition(aux.SpiritReturnConditionOptional)
	c:RegisterEffect(e2)
end
-- 效果②的Target函数：在强制发动时直接通过，在选发时检测2个怪兽区空位、非青眼精灵龙限制及衍生物可特召性，并设置回手与生成2只衍生物的操作信息
function c25415052.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
			return true
		else
			-- 检查己方主要怪兽区是否至少有2个可用空位以放置2只衍生物
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and not Duel.IsPlayerAffectedByEffect(tp,59822133)
				-- 检查己方是否可以特殊召唤「灵魂鸟衍生物」(25415053，鸟兽族·风·4星·攻/守1500)
				and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND)
		end
	end
	-- 设置将这张卡返回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	-- 设置特殊召唤2只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置将2只衍生物特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果②的Operation函数：将表侧表示的这张卡返回手卡后，若满足格子与召唤条件则在己方场上特殊召唤2只「灵魂鸟衍生物」
function c25415052.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡表侧在场且与效果关联，并将其以效果返回持有者手卡
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡回手后己方主要怪兽区至少有2个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 再次确认己方可以特殊召唤2只「灵魂鸟衍生物」(25415053)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND) then
		for i=1,2 do
			-- 为己方玩家生成1只「灵魂鸟衍生物」(25415053)卡片实例
			local token=Duel.CreateToken(tp,25415053)
			-- 以分步特殊召唤方式将当前生成的衍生物表侧特殊召唤到己方场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 统一完成2只「灵魂鸟衍生物」的分步特殊召唤并触发相关时点
		Duel.SpecialSummonComplete()
	end
end
