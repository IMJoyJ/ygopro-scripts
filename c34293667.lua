--氷結界
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽攻击力变成0，不能把表示形式变更，效果无效化。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只5星以上的水属性怪兽送去墓地。那之后，可以从自己墓地选1只水属性怪兽加入手卡。这个效果的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能特殊召唤。
function c34293667.initial_effect(c)
	-- ①：对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽攻击力变成0，不能把表示形式变更，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c34293667.target)
	e1:SetOperation(c34293667.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只5星以上的水属性怪兽送去墓地。那之后，可以从自己墓地选1只水属性怪兽加入手卡。这个效果的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34293667,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,34293667)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c34293667.tgtg)
	e2:SetOperation(c34293667.tgop)
	c:RegisterEffect(e2)
end
-- 检查对方战斗中的怪兽是否存在于战场上且表侧表示
function c34293667.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方战斗中的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if chk==0 then return tc and tc:IsRelateToBattle() and tc:IsFaceup() end
end
-- 当对方怪兽进行攻击宣言时发动，使该怪兽攻击力变为0，不能改变表示形式，效果无效化
function c34293667.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方战斗中的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 使与该怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使该怪兽的攻击力变为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使该怪兽不能改变表示形式
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使该怪兽效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 使该怪兽效果无效化
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
end
-- 过滤满足5星以上、水属性、怪兽类型且能送去墓地的卡
function c34293667.tgfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果发动时的处理信息，包括从卡组送去墓地和从墓地加入手牌
function c34293667.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34293667.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将要送去墓地的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤满足水属性、怪兽类型且能加入手牌的卡
function c34293667.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 处理效果发动后的操作，包括从卡组选卡送去墓地、从墓地选卡加入手牌，并设置水属性怪兽不能特殊召唤的效果
function c34293667.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并将其送去墓地
	local g=Duel.SelectMatchingCard(tp,c34293667.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认卡已成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取满足条件的墓地中的卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c34293667.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 询问玩家是否从墓地选卡加入手牌
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(34293667,1)) then  --"是否从墓地选1只水属性怪兽加入手卡？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
	-- 设置水属性怪兽不能特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34293667.splimit)
	-- 判断是否为当前回合玩家
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 注册水属性怪兽不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制非水属性怪兽特殊召唤
function c34293667.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
