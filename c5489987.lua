--花札衛－桜に幕－
-- 效果：
-- 这张卡不能通常召唤。这张卡的①的效果可以特殊召唤。
-- ①：把手卡的这张卡给对方观看才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，这张卡特殊召唤。不是的场合，那张卡和这张卡送去墓地。
-- ②：自己的「花札卫」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡丢弃才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升1000。
function c5489987.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，这张卡特殊召唤。不是的场合，那张卡和这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5489987,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c5489987.drcost)
	e1:SetTarget(c5489987.drtg)
	e1:SetOperation(c5489987.drop)
	c:RegisterEffect(e1)
	-- ②：自己的「花札卫」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡丢弃才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5489987,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(c5489987.atkcon)
	e2:SetCost(c5489987.atkcost)
	e2:SetOperation(c5489987.atkop)
	c:RegisterEffect(e2)
end
-- 检查手牌中的这张卡是否未给对方观看（作为发动Cost，要求这张卡在手牌中是非公开状态）。
function c5489987.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检查发动条件：玩家是否可以抽卡、自己场上是否有怪兽区域空位、以及这张卡是否可以无视召唤条件特殊召唤。
function c5489987.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡，以及自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置当前效果处理的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果处理的目标参数为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置当前效果处理的操作信息为：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的处理：抽1张卡并给双方确认，如果是「花札卫」怪兽则将这张卡特殊召唤，否则将抽到的卡和这张卡送去墓地。
function c5489987.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 尝试让目标玩家因效果抽指定数量的卡，并判断是否成功抽卡。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		-- 获取刚才因抽卡操作而加入手牌的卡片组。
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		-- 将抽到的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使后续的特殊召唤或送去墓地处理与抽卡不视为同时进行（会造成错时点）。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if c:IsRelateToEffect(e) then
				-- 尝试将这张卡无视召唤条件以表侧表示特殊召唤到自己场上，并判断是否特殊召唤成功。
				if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
					c:CompleteProcedure()
				end
			end
		else
			if c:IsRelateToEffect(e) then
				g:AddCard(c)
			end
			-- 将抽到的卡和这张卡送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
		-- 洗切自己的手牌。
		Duel.ShuffleHand(tp)
	end
end
-- 效果②的发动条件：在伤害步骤开始时到伤害计算前，自己的「花札卫」怪兽与对方怪兽进行战斗。
function c5489987.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local phase=Duel.GetCurrentPhase()
	-- 检查当前是否为伤害步骤，且尚未进行伤害计算。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击对象怪兽。
	local tc=Duel.GetAttackTarget()
	if not tc then return false end
	-- 如果攻击对象是对方怪兽，则将进行战斗的自己怪兽（攻击怪兽）作为目标。
	if tc:IsControler(1-tp) then tc=Duel.GetAttacker() end
	e:SetLabelObject(tc)
	return tc:IsFaceup() and tc:IsSetCard(0xe6) and tc:IsRelateToBattle()
end
-- 效果②的发动代价：将手牌中的这张卡丢弃。
function c5489987.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动Cost从手牌丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果②的处理：使进行战斗的那只自己怪兽的攻击力直到回合结束时上升1000。
function c5489987.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只进行战斗的自己怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
