--霊魂鳥神－彦孔雀
-- 效果：
-- 「灵魂的降神」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3只怪兽回到持有者手卡。那之后，可以从手卡把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
function c52900000.initial_effect(c)
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。选对方场上最多3只怪兽回到持有者手卡。那之后，可以从手卡把1只4星以下的灵魂怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置此卡必须通过仪式召唤方式特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡，在自己场上把2只「灵魂鸟衍生物」（鸟兽族·风·4星·攻/守1500）特殊召唤。
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
	-- 注册一个在特殊召唤成功时触发的效果，用于设置结束阶段返回手牌和召唤衍生物的触发效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c52900000.retreg)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为仪式召唤方式特殊召唤
function c52900000.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤满足条件的灵魂怪兽（4星以下且可特殊召唤）
function c52900000.spfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置连锁处理信息：选择目标怪兽送入对方手牌
function c52900000.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有对方场上怪兽可以送回手牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息为将怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 执行效果处理：选择并送回对方怪兽，然后从手卡特殊召唤灵魂怪兽
function c52900000.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有可送回手牌的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()<=0 then return end
	-- 提示玩家选择要送回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:Select(tp,1,3,nil)
	-- 将选中的怪兽送回手牌
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 获取实际被操作的怪兽组
		local sg2=Duel.GetOperatedGroup()
		if not sg2:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then return end
		-- 获取满足条件的灵魂怪兽（4星以下且可特殊召唤）
		local tg=Duel.GetMatchingGroup(c52900000.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 检查是否有灵魂怪兽可以特殊召唤，以及场上是否有空位
		if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否从手卡特殊召唤灵魂怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(52900000,1)) then  --"是否从手卡把灵魂怪兽特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的灵魂怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=tg:Select(tp,1,1,nil)
			-- 将选中的灵魂怪兽无视召唤条件特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 注册结束阶段触发的效果，用于返回手牌和召唤衍生物
function c52900000.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置结束阶段触发效果：在结束阶段将此卡送回手牌并召唤2只衍生物
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	-- 设置强制返回手牌的条件函数
	e1:SetCondition(aux.SpiritReturnConditionForced)
	e1:SetTarget(c52900000.rettg)
	e1:SetOperation(c52900000.retop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 设置可选择是否返回手牌的条件函数
	e2:SetCondition(aux.SpiritReturnConditionOptional)
	c:RegisterEffect(e2)
end
-- 设置结束阶段效果的目标处理信息：包括送回手牌、召唤衍生物和特殊召唤
function c52900000.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
			return true
		else
			-- 检查场上是否有足够的空位召唤衍生物
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and not Duel.IsPlayerAffectedByEffect(tp,59822133)
				-- 检查是否可以召唤衍生物（检测青眼精灵龙等限制）
				and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND)
		end
	end
	-- 设置操作信息为将此卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	-- 设置操作信息为召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息为特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 执行结束阶段效果处理：将此卡送回手牌并召唤2只衍生物
function c52900000.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍然在场且处于表侧表示状态，并成功将其送回手牌
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 检查场上是否有足够的空位召唤衍生物
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查是否可以召唤衍生物（检测青眼精灵龙等限制）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25415053,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_WINDBEAST,ATTRIBUTE_WIND) then
		for i=1,2 do
			-- 创建一只灵魂鸟衍生物
			local token=Duel.CreateToken(tp,52900001)
			-- 特殊召唤一只衍生物
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成所有衍生物的特殊召唤
		Duel.SpecialSummonComplete()
	end
end
