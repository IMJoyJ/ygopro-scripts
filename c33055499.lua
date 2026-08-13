--地雷蜘蛛の餌食
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成通常怪兽（昆虫族·地·5星·攻2100/守100）在正对面的自己的主要怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以把和这张卡相同纵列1只对方怪兽破坏。
-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
function c33055499.initial_effect(c)
	-- 记录这张卡上记载着「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的卡号，用于支持相关检索与联动判定。
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡发动后变成通常怪兽（昆虫族·地·5星·攻2100/守100）在正对面的自己的主要怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以把和这张卡相同纵列1只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33055499,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33055499)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c33055499.target)
	e1:SetOperation(c33055499.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33055499,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,33055500)
	-- 设置②效果的发动代价为‘把墓地的这张卡除外’：使用标准代价函数aux.bfgcost，在发动前将自身除外作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c33055499.thtg)
	e2:SetOperation(c33055499.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判断：获取本卡所在纵列序号，检查是否已通过代价检查、该纵列对应的自己的主要怪兽区域是否有空位，以及自己能否将本卡作为昆虫族·地·5星·攻2100/守100的通常怪兽（陷阱卡）特殊召唤。
function c33055499.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local seq=e:GetHandler():GetSequence()
	if chk==0 then return e:IsCostChecked()
		-- 检查这张卡所在纵列（序号seq）对应的自己的主要怪兽区域是否为空位，以确保能特殊召唤到正对面的主要怪兽区域。
		and Duel.CheckLocation(tp,LOCATION_MZONE,seq)
		-- 检查自己是否能够在场上特殊召唤这只由本卡变成的通常怪兽（昆虫族·地·5星·攻2100/守100，也当作陷阱卡使用）；若不可行则不能发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,33055499,0,TYPES_NORMAL_TRAP_MONSTER,2100,100,5,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 将本次连锁必须发生的特殊召唤信息（对象为本卡）写入操作信息，供其他卡效果检测：本次处理将包含特殊召唤行为。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义筛选函数：选取对方场上位于主要怪兽区域的怪兽，用于后续找出与这张卡处于同一纵列的对方怪兽。
function c33055499.filter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end
-- ①效果解决：再次确认玩家能特召此卡后，用AddMonsterAttribute将本卡变为通常怪兽（昆虫族·地·5星·攻2100/守100，也当作陷阱卡），并以正面表示特殊召唤到其所在纵列对应的自己的主要怪兽区域；若特召成功，则获取与它同一纵列的对方怪兽组，若存在则询问发动者是否破坏，选‘是’时先中断效果使破坏单独处理，若可选的怪兽多于1只则由玩家选择其中1只，最后将所选怪兽以效果破坏。
function c33055499.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	local zone=1<<seq
	-- 处理时若玩家已经无法特殊召唤此陷阱怪兽，则中止处理（例如区域被占用或特殊召唤被禁止时）。注意这里再一次检查是为了处理时点有效性。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,33055499,0,TYPES_NORMAL_TRAP_MONSTER,2100,100,5,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 实际执行特殊召唤：以效果方式将此卡特殊召唤到zone（由自身纵列计算出的主要怪兽区域），正面表示；nocheck=true表示不检查召唤条件，nolimit=false表示仍受苏生限制；返回值非0表示特召成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP,zone)~=0 then
		local g=c:GetColumnGroup():Filter(c33055499.filter,nil,tp)
		-- 当同一纵列存在对方怪兽时，弹出询问‘是否把对方怪兽破坏？’，由玩家决定是否执行破坏；选择否则跳过破坏。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(33055499,2)) then  --"是否把对方怪兽破坏？"
			-- 中断当前效果处理，使后续的破坏不在特殊召唤成功的同一时点进行，避免与其他时点效果产生互挤或卡时点。
			Duel.BreakEffect()
			local tg=g:Clone()
			if #tg>1 then
				-- 在需要从多张同列怪兽中选择1张时，先显示‘请选择要破坏的卡’的选卡提示。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				tg=g:Select(tp,1,1,nil)
			end
			-- 为最终选中的破坏对象播放选中动画并登记对象信息，使该卡与本次效果建立对象联系。
			Duel.HintSelection(tg)
			-- 将选定的对象怪兽以效果原因（REASON_EFFECT）破坏。
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
-- 定义②效果的检索对象条件：必须是表侧表示（或除外区可确认）的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」之一，且能够加入手牌。
function c33055499.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877) and c:IsAbleToHand()
end
-- ②效果的发动条件判定与操作信息设置：确认自己卡组或除外区存在至少1张符合条件的指定魔神卡，并登记为从卡组/除外区将1张卡加入手牌的处理。
function c33055499.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动时检查：自己的卡组或除外区是否至少存在1张符合条件的指定魔神卡；有才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33055499.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 将本次处理登记为‘从卡组·除外区把1张卡加入手牌’的操作信息（数量1，对象未定），供连锁检测等机制使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- ②效果的处理：让发动者从自己的卡组或除外区选择1张符合条件的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」，将其加入手牌，并向对方玩家展示。
function c33055499.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的提示，进入选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·除外状态中选出1张符合条件的指定卡片（数量必须为1），由玩家手动选择。
	local g=Duel.SelectMatchingCard(tp,c33055499.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入其持有者的手牌（原因REASON_EFFECT）；这里nil表示加入原持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示已加入手牌的那张卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
