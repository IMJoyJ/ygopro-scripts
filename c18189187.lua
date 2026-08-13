--夢魔鏡の使徒－ネイロイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有「梦魔镜」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡变成暗属性。
-- ②：这张卡用「梦魔镜」怪兽的效果特殊召唤成功的场合发动。场上有「圣光之梦魔镜」存在的场合，可以选对方场上1张魔法·陷阱卡回到持有者手卡。场上有「黯黑之梦魔镜」存在的场合，自己从卡组抽1张，那之后1张手卡回到卡组。
function c18189187.initial_effect(c)
	-- 将该卡在规则上记载的卡名「圣光之梦魔镜」（74665651）和「黯黑之梦魔镜」（1050355）登记到代码列表中，用于相关效果判定。
	aux.AddCodeList(c,74665651,1050355)
	-- 这个卡名的①②的效果1回合各能使用1次。①：场上有「梦魔镜」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡变成暗属性。
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
-- 定义筛选条件：卡片须为表侧表示且属于「梦魔镜」系列（0x131），用于判断场上是否存在符合条件的梦魔镜怪兽。
function c18189187.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x131)
end
-- ①效果的发动条件：双方主要怪兽区存在至少1张表侧表示的「梦魔镜」怪兽。
function c18189187.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp视角双方的怪兽区域，是否存在至少1张满足c18189187.filter的卡片，即表侧表示的「梦魔镜」怪兽。
	return Duel.IsExistingMatchingCard(c18189187.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的发动目标检查：确认我方主要怪兽区有可用空位，且这张卡自身能够被特殊召唤；满足则允许发动。
function c18189187.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检查（chk==0）时，判断我方主要怪兽区是否存在至少1个空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：效果将特殊召唤的对象是这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则将其特殊召唤；若召唤成功且此卡不是暗属性，则询问玩家是否将其变成暗属性；同意后中断效果链并给此卡附加改变为暗属性的永续效果。
function c18189187.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行此卡从手卡特殊召唤；若特殊召唤成功且此卡当前不是暗属性，则继续后续变成暗属性的询问。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and not c:IsAttribute(ATTRIBUTE_DARK)
			-- 弹出“是否把这张卡变成暗属性？”的选择询问，玩家选择“是”时才执行后续变属性处理。
			and Duel.SelectYesNo(tp,aux.Stringid(18189187,1)) then  --"是否把这张卡变成暗属性？"
			-- 中断当前效果处理，使后续改变属性的处理与之前的特殊召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 那之后，可以把这张卡变成暗属性。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_DARK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- ②效果的发动条件：此卡是被「梦魔镜」怪兽的效果成功特殊召唤的场合（通过特殊召唤信息中的类型和来源系列进行判断）。
function c18189187.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x131)
end
-- 定义可回手的对方魔法·陷阱卡的筛选条件：卡的类型为魔法或陷阱，且当前能够被加入手卡。
function c18189187.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果发动时登记操作信息：若场地区有「圣光之梦魔镜」，则登记对方场上1张卡回手；若场地区有「黯黑之梦魔镜」，则登记抽1张卡并随后将1张手卡返回卡组。
function c18189187.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查当前生效的场地卡是否为「圣光之梦魔镜」（74665651），且不论控制者，生效区域为场地区。
	if Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE) then
		-- 登记效果操作：将对方场上1张魔法·陷阱卡返回持有者手卡（目标数量1，目标持有者为对方，位置为场上）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
	end
	-- 检查当前生效的场地卡是否为「黯黑之梦魔镜」（1050355），且不论控制者，生效区域为场地区。
	if Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE) then
		-- 登记效果操作：当前玩家从卡组抽1张卡。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
		-- 登记效果操作：当前玩家将1张手卡返回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	end
end
-- ②效果处理：若场上有「圣光之梦魔镜」且对方场上存在符合条件的魔法·陷阱卡，则询问是否选1张返回手卡；若场上有「黯黑之梦魔镜」，则抽1张，若成功则选择1张手卡返回卡组洗牌。
function c18189187.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场地区生效且为「圣光之梦魔镜」时，执行对应的回手效果部分。
	if Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
		-- 检查对方场上是否存在至少1张满足thfilter的魔法·陷阱卡，即是否存在可回手的目标。
		and Duel.IsExistingMatchingCard(c18189187.thfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问当前玩家是否选择对方场上1张魔法·陷阱卡返回手卡。
		and Duel.SelectYesNo(tp,aux.Stringid(18189187,2)) then  --"是否选对方魔法·陷阱卡回到手卡？"
		-- 将“请选择要返回手牌的卡”的提示信息写入选择缓存，供后续选择卡时显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让当前玩家从对方场上的卡中选择1张符合thfilter的魔法·陷阱卡，作为回手对象。
		local g=Duel.SelectMatchingCard(tp,c18189187.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 为选中的卡片显示被选择动画效果，并将其记录为效果的对象（广义对象记录）。
			Duel.HintSelection(g)
			-- 将选中的卡以效果原因返回其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
	-- 在场地区生效且为「黯黑之梦魔镜」时，执行对应的抽卡及回卡组效果部分。
	if Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE) then
		-- 让当前玩家以效果原因抽1张卡；若实际抽卡数为0则终止后续处理。
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 将“请选择要返回卡组的卡”的提示信息写入选择缓存，供后续选择手牌时显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让当前玩家从自己的手牌中选择1张可以回到卡组的卡。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使“抽卡”和“1张手卡回到卡组”视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选中的手牌以效果原因返回持有者卡组，并因为返回卡组顶端之外的顺序而触发洗牌。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
