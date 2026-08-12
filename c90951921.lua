--先史遺産技術
-- 效果：
-- 选择自己墓地1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽从游戏中除外。那之后，从自己卡组上面把2张卡确认，从那之中选1张加入手卡，剩下的卡送去墓地。「先史遗产技术」在1回合只能发动1张，这张卡发动的回合自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
function c90951921.initial_effect(c)
	-- 选择自己墓地1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽从游戏中除外。那之后，从自己卡组上面把2张卡确认，从那之中选1张加入手卡，剩下的卡送去墓地。「先史遗产技术」在1回合只能发动1张，这张卡发动的回合自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90951921+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c90951921.cost)
	e1:SetTarget(c90951921.target)
	e1:SetOperation(c90951921.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测本回合玩家特殊召唤非「先史遗产」怪兽的次数。
	Duel.AddCustomActivityCounter(90951921,ACTIVITY_SPSUMMON,c90951921.counterfilter)
end
-- 计数器过滤函数，用于判定特殊召唤的怪兽是否为「先史遗产」怪兽。
function c90951921.counterfilter(c)
	return c:IsSetCard(0x70)
end
-- 效果发动代价（Cost）处理函数，检查本回合是否曾特殊召唤过非「先史遗产」怪兽，并注册本回合不能特殊召唤非「先史遗产」怪兽的限制。
function c90951921.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查本回合玩家是否未曾特殊召唤过非「先史遗产」怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(90951921,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。选择自己墓地1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽从游戏中除外。那之后，从自己卡组上面把2张卡确认，从那之中选1张加入手卡，剩下的卡送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c90951921.splimit)
	-- 将不能特殊召唤非「先史遗产」怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数，限制不能特殊召唤非「先史遗产」怪兽。
function c90951921.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x70)
end
-- 过滤自己墓地中可以被除外的「先史遗产」怪兽。
function c90951921.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x70) and c:IsAbleToRemove()
end
-- 效果发动条件与对象选择（Target）处理函数，检查卡组是否有足够数量的卡、墓地是否有符合条件的怪兽，并进行对象选择。
function c90951921.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90951921.filter(chkc) end
	if chk==0 then
		-- 检查玩家是否能将卡组顶端的2张卡送去墓地（即卡组是否至少有2张卡）。
		if not Duel.IsPlayerCanDiscardDeck(tp,2)
			-- 或者检查自己墓地是否存在至少1只符合条件的「先史遗产」怪兽，若不满足则无法发动。
			or not Duel.IsExistingTarget(c90951921.filter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		-- 获取玩家卡组最上方的2张卡。
		local g=Duel.GetDecktopGroup(tp,2)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 给玩家发送选择要除外的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只符合条件的「先史遗产」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c90951921.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果包含将墓地的1张卡除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	-- 设置当前连锁的操作信息，表示该效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理（Operation）函数，执行除外墓地怪兽、确认卡组顶端卡片、加入手牌及送去墓地的具体操作。
function c90951921.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍对该效果有效，若成功将其表侧表示除外，且此时玩家仍能将卡组顶端2张卡送去墓地，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and Duel.IsPlayerCanDiscardDeck(tp,2) then
		-- 中断当前效果处理，使后续的确认卡片、加入手牌等操作与除外操作不视为同时进行（会造成错时点）。
		Duel.BreakEffect()
		-- 获取玩家卡组最上方的2张卡。
		local g=Duel.GetDecktopGroup(tp,2)
		-- 给玩家确认这2张卡。
		Duel.ConfirmCards(tp,g)
		if g:GetCount()>0 then
			-- 给玩家发送选择要加入手牌的卡的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			g:Sub(sg)
			if sg:GetCount()>0 then
				-- 禁用接下来的洗牌检测，防止在将卡片加入手牌时自动洗卡组。
				Duel.DisableShuffleCheck()
				-- 将选择的1张卡加入玩家手牌。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
			end
			if g:GetCount()>0 then
				-- 再次禁用洗牌检测，防止在将剩余卡片送去墓地时自动洗卡组。
				Duel.DisableShuffleCheck()
				-- 将剩下的卡送去墓地。
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
