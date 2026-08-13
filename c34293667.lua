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
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从卡组把1只5星以上的水属性怪兽送去墓地。那之后，可以从自己墓地选1只水属性怪兽加入手卡。这个效果的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34293667,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,34293667)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置②效果的发动代价为将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c34293667.tgtg)
	e2:SetOperation(c34293667.tgop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：对方怪兽进行战斗攻击宣言时，且该怪兽存在并表侧表示且与战斗相关。
function c34293667.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方玩家（1-tp）正在战斗中的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	if chk==0 then return tc and tc:IsRelateToBattle() and tc:IsFaceup() end
end
-- 定义①效果的处理：若对方战斗怪兽仍存在且表侧表示，则使其攻击力变为0、不能变更表示形式、效果无效化，同时使与其相关的连锁无效。
function c34293667.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方玩家（1-tp）正在战斗中的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 使与目标怪兽相关的连锁无效化，并在该怪兽变里侧时重置此无效状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只对方怪兽攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 不能把表示形式变更
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 效果无效化
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
	end
end
-- 定义②效果中从卡组送墓的过滤条件：5星以上、水属性、怪兽卡且可以被送去墓地。
function c34293667.tgfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义②效果的发动条件和操作信息：卡组中存在符合条件的5星以上水属性怪兽时才可发动，并设置从卡组送墓1只怪兽的操作信息。
function c34293667.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的5星以上水属性怪兽，作为②效果可否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c34293667.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理将执行‘从卡组把1只5星以上的水属性怪兽送去墓地’的操作信息，供其他卡进行连锁响应判断。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义从墓地加入手卡的过滤条件：水属性怪兽卡且可以被加入手卡。
function c34293667.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义②效果的处理：从卡组选1只5星以上水属性怪兽送去墓地；那之后可选择1只墓地水属性怪兽加入手卡；最后赋予‘直到下次自己回合结束时，自己不是水属性怪兽不能特殊召唤’的自肃效果。
function c34293667.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示‘请选择要送去墓地的卡’的提示，用于卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让发动玩家从卡组选择1张满足条件的5星以上水属性怪兽，该选择在效果处理时进行（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c34293667.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择并确认该卡被效果送去墓地、且现在位于墓地，则继续执行后续可能加入手卡的处理；否则跳过。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取自己墓地的所有满足条件且不受王家长眠之谷影响的水属性怪兽，作为可加入手卡的候选组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c34293667.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若存在可加入手卡的墓地水属性怪兽，则询问发动玩家是否选择1只加入手卡。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(34293667,1)) then  --"是否从墓地选1只水属性怪兽加入手卡？"
			-- 中断当前效果处理，使‘从卡组送墓’与‘从墓地加入手卡’视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 向发动玩家显示‘请选择要加入手牌的卡’的提示，用于卡片选择界面。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的水属性怪兽加入其持有者的手卡，原因为效果。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
	-- 这个效果的发动后，直到下次的自己回合的结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34293667.splimit)
	-- 判断当前回合玩家是否为发动玩家，以确定自肃效果持续到下一次自己的结束阶段还是两次自己的结束阶段。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 将自肃效果注册到场上，对发动玩家持续生效，限制其特殊召唤非水属性怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的适用条件：仅允许特殊召唤水属性怪兽，即非水属性怪兽不能特殊召唤。
function c34293667.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
