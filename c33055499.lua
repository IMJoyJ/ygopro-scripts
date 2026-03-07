--地雷蜘蛛の餌食
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成通常怪兽（昆虫族·地·5星·攻2100/守100）在正对面的自己的主要怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以把和这张卡相同纵列1只对方怪兽破坏。
-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
function c33055499.initial_effect(c)
	-- 注册该卡牌所关联的其他卡牌代码，用于识别其效果中涉及的魔神卡
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- ①：这张卡发动后变成通常怪兽（昆虫族·地·5星·攻2100/守100）在正对面的自己的主要怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以把和这张卡相同纵列1只对方怪兽破坏。
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
	-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33055499,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,33055500)
	-- 设置效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c33055499.thtg)
	e2:SetOperation(c33055499.thop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤条件，包括目标区域是否可用及是否可以特殊召唤该怪兽
function c33055499.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local seq=e:GetHandler():GetSequence()
	if chk==0 then return e:IsCostChecked()
		-- 检查目标玩家的场上目标位置是否为空
		and Duel.CheckLocation(tp,LOCATION_MZONE,seq)
		-- 检查目标玩家是否可以特殊召唤该怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,33055499,0,TYPES_NORMAL_TRAP_MONSTER,2100,100,5,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置连锁处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义过滤函数，用于筛选对方场上的怪兽
function c33055499.filter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end
-- 执行效果的主要处理函数，包括将卡特殊召唤并可能破坏对方怪兽
function c33055499.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	local zone=1<<seq
	-- 检查是否可以特殊召唤该怪兽，若不可则返回
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,33055499,0,TYPES_NORMAL_TRAP_MONSTER,2100,100,5,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 执行特殊召唤操作，将此卡以特殊召唤方式放入场上
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP,zone)~=0 then
		local g=c:GetColumnGroup():Filter(c33055499.filter,nil,tp)
		-- 判断是否有对方怪兽可破坏，并询问玩家是否选择破坏
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(33055499,2)) then  --"是否把对方怪兽破坏？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			local tg=g:Clone()
			if #tg>1 then
				-- 提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				tg=g:Select(tp,1,1,nil)
			end
			-- 显示被选为对象的卡
			Duel.HintSelection(tg)
			-- 执行破坏操作
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
-- 定义过滤函数，用于筛选可加入手牌的魔神卡
function c33055499.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877) and c:IsAbleToHand()
end
-- 设置检索魔神卡的效果目标
function c33055499.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的魔神卡可加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c33055499.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁处理信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 执行检索魔神卡的效果处理函数
function c33055499.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔神卡
	local g=Duel.SelectMatchingCard(tp,c33055499.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
