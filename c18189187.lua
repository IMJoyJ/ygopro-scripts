--夢魔鏡の使徒－ネイロイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有「梦魔镜」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡变成暗属性。
-- ②：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合发动。场上有「圣光之梦魔镜」存在的场合，可以选对方场上1张魔法·陷阱卡回到持有者手卡。场上有「黯黑之梦魔镜」存在的场合，自己从卡组抽1张，那之后1张手卡回到卡组。
function c18189187.initial_effect(c)
	-- 记录该卡牌具有「圣光之梦魔镜」和「黯黑之梦魔镜」的卡名信息
	aux.AddCodeList(c,74665651,1050355)
	-- ①：场上有「梦魔镜」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡变成暗属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18189187,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18189187)
	e1:SetCondition(c18189187.spcon)
	e1:SetTarget(c18189187.sptg)
	e1:SetOperation(c18189187.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合发动。场上有「圣光之梦魔镜」存在的场合，可以选对方场上1张魔法·陷阱卡回到持有者手卡。场上有「黯黑之梦魔镜」存在的场合，自己从卡组抽1张，那之后1张手卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18189187,3))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,18189188)
	e2:SetCondition(c18189187.thcon)
	e2:SetTarget(c18189187.thtg)
	e2:SetOperation(c18189187.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「梦魔镜」怪兽（暗属性）
function c18189187.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x131)
end
-- 效果条件函数，判断场上是否存在「梦魔镜」怪兽
function c18189187.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张「梦魔镜」怪兽
	return Duel.IsExistingMatchingCard(c18189187.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 特殊召唤效果的目标设定函数
function c18189187.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c18189187.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作并判断是否为暗属性
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and not c:IsAttribute(ATTRIBUTE_DARK)
			-- 询问玩家是否将该卡变为暗属性
			and Duel.SelectYesNo(tp,aux.Stringid(18189187,1)) then  --"是否把这张卡变成暗属性？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 创建改变属性的效果，将该卡变为暗属性
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_DARK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 诱发效果的条件函数，判断该卡是否为「梦魔镜」怪兽特殊召唤
function c18189187.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 过滤函数，用于筛选可送回手牌的魔法·陷阱卡
function c18189187.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 诱发效果的目标设定函数，根据场地卡状态设置处理信息
function c18189187.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查是否存在「圣光之梦魔镜」场地卡
	if Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE) then
		-- 设置将对方场上1张魔法·陷阱卡送回手牌的处理信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
	end
	-- 检查是否存在「黯黑之梦魔镜」场地卡
	if Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE) then
		-- 设置自己抽1张卡的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
		-- 设置将自己1张手卡送回卡组的处理信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	end
end
-- 诱发效果的处理函数，根据场地卡状态执行效果
function c18189187.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在「圣光之梦魔镜」场地卡
	if Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
		-- 检查对方场上是否存在至少1张魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c18189187.thfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否选择对方魔法·陷阱卡送回手牌
		and Duel.SelectYesNo(tp,aux.Stringid(18189187,2)) then  --"是否选对方魔法·陷阱卡回到手卡？"
		-- 提示玩家选择要送回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上1张魔法·陷阱卡作为目标
		local g=Duel.SelectMatchingCard(tp,c18189187.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将所选卡送回对方手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
	-- 检查是否存在「黯黑之梦魔镜」场地卡
	if Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE) then
		-- 执行自己从卡组抽1张卡的操作
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择自己1张手卡作为目标
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 将所选卡送回卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
