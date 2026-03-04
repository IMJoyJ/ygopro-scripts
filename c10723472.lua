--バーニング・ソウル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有8星以上的同调怪兽存在的场合才能发动。「燃烧之魂」以外的自己墓地1张卡加入手卡。那之后，进行1只同调怪兽的同调召唤。这张卡的发动后，直到回合结束时对方不能把场上的同调怪兽作为效果的对象。
function c10723472.initial_effect(c)
	-- 创建效果，设置效果分类为回手牌和特殊召唤，效果类型为发动，时点为自由连锁，发动次数限制为1次，条件为己方场上存在8星以上同调怪兽，目标为选择墓地卡和额外卡，效果处理为activate函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,10723472+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10723472.condition)
	e1:SetTarget(c10723472.target)
	e1:SetOperation(c10723472.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在8星以上且为同调怪兽的怪兽
function c10723472.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO)
end
-- 判断条件函数，用于判断是否满足发动条件
function c10723472.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只8星以上的同调怪兽
	return Duel.IsExistingMatchingCard(c10723472.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断墓地是否存在非燃烧之魂且可加入手牌的卡
function c10723472.thfilter(c)
	return not c:IsCode(10723472) and c:IsAbleToHand()
end
-- 目标函数，用于设置效果发动时的处理信息
function c10723472.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查己方墓地是否存在至少1张可加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10723472.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 同时检查己方额外卡组是否存在至少1只可同调召唤的怪兽
		and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置操作信息，指定将1张墓地卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息，指定将1只额外卡组怪兽进行同调召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，用于执行效果发动后的处理
function c10723472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从己方墓地选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10723472.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若选择的卡成功加入手牌，则进行后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取己方额外卡组中所有可同调召唤的怪兽
		local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
		if sg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的同调怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local pg=sg:Select(tp,1,1,nil)
			-- 进行选定的同调怪兽的同调召唤
			Duel.SynchroSummon(tp,pg:GetFirst(),nil)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 创建效果，使对方在本回合不能以场上的同调怪兽为对象发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(c10723472.tglimit)
		-- 设置效果值为tgoval函数，用于判断是否能成为对方效果的对象
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 目标限制函数，用于判断是否为场上的同调怪兽
function c10723472.tglimit(e,c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
