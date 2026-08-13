--アームズ・コール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张装备魔法卡加入手卡。那之后，可以给可以把那张卡装备的自己场上1只怪兽装备。
function c38960450.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1张装备魔法卡加入手卡。那之后，可以给可以把那张卡装备的自己场上1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38960450+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38960450.target)
	e1:SetOperation(c38960450.activate)
	c:RegisterEffect(e1)
end
-- 定义检索过滤函数：筛选卡组中的装备魔法卡，且该卡能够被加入手卡。
function c38960450.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 发动时的目标处理函数：进行发动合法性检查，并设置效果处理时的操作信息。
function c38960450.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的装备魔法卡，作为效果发动的合法条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c38960450.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本效果处理时将执行“从卡组把1张卡加入手卡”的操作信息，便于后续连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义装备过滤函数：选择自己场上表侧表示的、且能够装备这张装备魔法卡的怪兽。
function c38960450.eqfilter(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end
-- 效果处理函数：实际执行从卡组检索装备魔法卡，并选择是否将其装备给自己场上的合法怪兽。
function c38960450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中挑选1张满足过滤条件的装备魔法卡加入手卡（取自身卡组，不取对象）。
	local g1=Duel.SelectMatchingCard(tp,c38960450.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g1:GetFirst()
	-- 确认检索到的卡确实成功加入手卡且仍位于手牌（避免被置换或干扰），才继续后续装备处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g1)
		-- 获取自己场上所有能够装备这张检索到的装备魔法卡的表侧表示怪兽。
		local g2=Duel.GetMatchingGroup(c38960450.eqfilter,tp,LOCATION_MZONE,0,nil,tc)
		-- 检查该装备魔法卡是否满足场上唯一性、是否未被禁止，以及自己魔陷区是否有空位可以装备。
		if tc:CheckUniqueOnField(tp) and not tc:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 同时还需存在可装备的怪兽，且玩家选择“是”确认装备，才执行装备动作。
			and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(38960450,0)) then  --"是否给怪兽装备？"
			-- 中断当前效果链的时点，使“检索”与“装备”作为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 给玩家弹出选择提示，提示文字为“请选择表侧表示的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local sg=g2:Select(tp,1,1,nil)
			-- 将装备魔法卡装备给玩家选择的怪兽，完成装备处理。
			Duel.Equip(tp,tc,sg:GetFirst())
		end
	end
end
