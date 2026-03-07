--アームズ・コール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张装备魔法卡加入手卡。那之后，可以给可以把那张卡装备的自己场上1只怪兽装备。
function c38960450.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38960450+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38960450.target)
	e1:SetOperation(c38960450.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以加入手牌的装备魔法卡。
function c38960450.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果原文内容：①：从卡组把1张装备魔法卡加入手卡。
function c38960450.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在满足条件的装备魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c38960450.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将从卡组检索一张装备魔法卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选可以装备该装备卡的场上怪兽。
function c38960450.eqfilter(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end
-- 效果原文内容：①：从卡组把1张装备魔法卡加入手卡。那之后，可以给可以把那张卡装备的自己场上1只怪兽装备。
function c38960450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张要加入手牌的装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张装备魔法卡加入手牌。
	local g1=Duel.SelectMatchingCard(tp,c38960450.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g1:GetFirst()
	-- 确认装备魔法卡成功加入手牌后执行后续操作。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示所选的装备魔法卡。
		Duel.ConfirmCards(1-tp,g1)
		-- 获取可以装备该装备卡的场上怪兽数组。
		local g2=Duel.GetMatchingGroup(c38960450.eqfilter,tp,LOCATION_MZONE,0,nil,tc)
		-- 检查装备卡是否满足场上唯一性、是否被禁止、场上是否有空魔陷区。
		if tc:CheckUniqueOnField(tp) and not tc:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 判断是否选择将装备卡装备给怪兽。
			and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(38960450,0)) then  --"是否给怪兽装备？"
			-- 中断当前效果处理，使之后的效果视为不同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择一张要装备的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local sg=g2:Select(tp,1,1,nil)
			-- 将装备卡装备给指定的怪兽。
			Duel.Equip(tp,tc,sg:GetFirst())
		end
	end
end
