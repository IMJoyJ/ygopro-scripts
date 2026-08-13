--古代の機械暗黒巨人
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「古代的机械巨人」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」合计最多2张从卡组加入手卡。那之后，选自己1张手卡丢弃。这个效果的发动后，直到回合结束时自己不能把卡盖放。
-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c64603182.initial_effect(c)
	-- 为这张卡注册永续效果：这张卡的卡名只要在场上·墓地存在就当作「古代的机械巨人」使用。
	aux.EnableChangeCode(c,83104731,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」合计最多2张从卡组加入手卡。那之后，选自己1张手卡丢弃。这个效果的发动后，直到回合结束时自己不能把卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64603182,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,64603182)
	e1:SetTarget(c64603182.thtg)
	e1:SetOperation(c64603182.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c64603182.aclimit)
	e3:SetCondition(c64603182.actcon)
	c:RegisterEffect(e3)
end
-- 检索过滤函数：筛选除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」中能够加入手卡的卡。
function c64603182.thfilter(c)
	return not c:IsCode(64603182) and (c:IsSetCard(0x7) or c:IsCode(37694547)) and c:IsAbleToHand()
end
-- ②效果的目标函数：检查卡组中是否存在可加入手卡的满足条件的卡，并设置对应的操作信息。
function c64603182.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c64603182.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果将要从卡组把卡加入手卡（预计1张，实际张数在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：从卡组选1-2张满足条件的卡加入手卡并给对方确认，然后选自己1张手卡丢弃，最后注册直到回合结束时自己不能把卡盖放的限制效果。
function c64603182.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1-2张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c64603182.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使之后的丢弃手卡不与加入手卡作为同时处理（错时点）。
		Duel.BreakEffect()
		-- 向玩家提示「请选择要丢弃的手牌」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让自己从手卡选择1张可以丢弃的卡。
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 将选中的手卡作为效果丢弃送去墓地。
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把卡盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 设置该限制对所有卡适用（条件函数始终成立）。
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「不能把怪兽盖放（里侧守备表示通常召唤）」的限制注册为发动者自己的玩家效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 把「不能把魔法·陷阱卡盖放」的限制注册为发动者自己的玩家效果。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 把「不能把场上的卡变为里侧表示」的限制注册为发动者自己的玩家效果。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c64603182.sumlimit)
	-- 把「不能以里侧表示特殊召唤」的限制注册为发动者自己的玩家效果。
	Duel.RegisterEffect(e4,tp)
end
-- 限制过滤函数：判断特殊召唤的表示形式是否包含里侧表示，是则禁止该特殊召唤。
function c64603182.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 限制函数：判断对方要发动的是否为魔法·陷阱卡的发动，是则禁止发动。
function c64603182.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 生效条件函数：仅在这张卡自身攻击的场合使该限制适用。
function c64603182.actcon(e)
	-- 判断此次战斗的攻击怪兽是否为这张卡本身。
	return Duel.GetAttacker()==e:GetHandler()
end
