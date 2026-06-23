--霊魂鳥神－彦孔雀
-- 效果：
-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3只怪兽回到持有者手卡。那之后，可以从手卡把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c52900000.initial_effect(c)
	-- 将「灵魂的降神」(73055622)加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 限制该卡不用仪式召唤不能特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3只怪兽回到持有者手卡。那之后，可以从手卡把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52900000,0))  --"对方怪兽回到手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c52900000.thcon)
	e2:SetTarget(c52900000.thtg)
	e2:SetOperation(c52900000.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c52900000.retreg)
	c:RegisterEffect(e3)
end
-- 判定发动条件：这张卡必须是仪式召唤成功的场合
function c52900000.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤手卡中4星以下的灵魂怪兽且该怪兽能无视召唤条件被特殊召唤
function c52900000.spfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动的目标判定与操作信息注册：判定对方场上是否有能返回手牌的怪兽并设定分类为送回手卡
function c52900000.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定对方场上是否存在至少1只可以送回手牌的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 注册将怪兽送回手牌的操作分类和相关信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 效果处理：选择对方场上最多3只怪兽送回手牌，若有怪兽成功返回手牌，可进一步选择无视召唤条件特殊召唤手卡1只4星以下的灵魂怪兽
function c52900000.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有能送回手牌的怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()<=0 then return end
	-- 在界面上提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:Select(tp,1,3,nil)
	-- 如果选中的怪兽成功送回持有者手卡
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 获取在刚刚的操作中实际送回手牌的卡片组
		local sg2=Duel.GetOperatedGroup()
		if not sg2:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then return end
		-- 过滤并获取玩家手卡中符合特殊召唤条件的灵魂怪兽
		local tg=Duel.GetMatchingGroup(c52900000.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 判定手卡中是否有满足特招条件的灵魂怪兽，并且自己场上的怪兽区域是否有空位
		if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从手卡将灵魂怪兽特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(52900000,1)) then  --"是否从手卡把灵魂怪兽特殊召唤？"
			-- 中断当前效果，使得之后手卡特招的处理与前面回手牌处理不视为同时发生
			Duel.BreakEffect()
			-- 在界面上提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=tg:Select(tp,1,1,nil)
			-- 将选中的灵魂怪兽无视召唤条件、以表侧表示特殊召唤到玩家自己场上
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 在特殊召唤成功的场合，为该卡注册一个在特殊召唤回合的结束阶段时发动的诱发效果，用于实现弹回手牌并特殊召唤衍生物的操作
function c52900000.retreg(e,tp,eg,ep,ev,re,r,rp)
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
	-- 设置当卡片正常状态（没有免疫或允许不返回的效果）下强制执行结束阶段弹回手牌的判定条件
	e1:SetCondition(aux.SpiritReturnConditionForced)
	e1:SetTarget(c52900000.rettg)
	e1:SetOperation(c52900000.retop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 设置在玩家拥有可选择是否弹回效果时所适用的非强制判定条件
	e2:SetCondition(aux.SpiritReturnConditionOptional)
	c:RegisterEffect(e2)
end
-- 判定结束阶段效果发动的可行性：若是强制发动的场合直接返回真，否则需判定是否有足够的怪兽区空格且允许特招衍生物，并在发动时注册弹回手牌与特招的操作信息
function c52900000.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
			return true
		else
			-- 判定自己场上可用的怪兽区域空格是否大于1个
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and not Duel.IsPlayerAffectedByEffect(tp,59822133)
				-- 判定玩家是否可以特殊召唤「灵魂鸟衍生物」
				and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND)
		end
	end
	-- 注册将自身（彦孔雀）送回持有者手牌的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	-- 注册生成衍生物的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 注册特殊召唤2只衍生物的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若此卡仍在场上且表侧表示，则将其送回持有者手卡，并无视召唤条件特殊召唤2只「灵魂鸟衍生物」到自己场上
function c52900000.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若该卡片因该效果仍然与场上关联、处于表侧表示且成功送回持有者手卡
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 判定自己场上的可用怪兽区域空格是否在2个以上
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定玩家是否可以特殊召唤「灵魂鸟衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND) then
		for i=1,2 do
			-- 在玩家自己场上创建「灵魂鸟衍生物」(52900001)卡片的数据对象
			local token=Duel.CreateToken(tp,52900001)
			-- 以表侧表示将衍生物特殊召唤至怪兽区域（完成步骤之一）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成所有步骤的特殊召唤处理并使召唤成功判定生效
		Duel.SpecialSummonComplete()
	end
end
