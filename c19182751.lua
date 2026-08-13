--ジェネクス・ニュートロン
-- 效果：
-- ①：这张卡召唤的回合的结束阶段才能发动。从卡组把1只机械族调整加入手卡。
function c19182751.initial_effect(c)
	-- ①：这张卡召唤的回合的结束阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c19182751.regop)
	c:RegisterEffect(e1)
end
-- 在召唤成功时注册一个结束阶段才能发动的诱发效果，该效果在本回合结束阶段后重置，且一回合最多发动一次。
function c19182751.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组把1只机械族调整加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(19182751,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetTarget(c19182751.target)
	e1:SetOperation(c19182751.operation)
	e1:SetReset(RESET_EVENT+0x16c0000+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 定义检索条件：满足机械族、调整、且可以被加入手卡的卡。
function c19182751.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果发动时的条件判定与操作信息登记：确认卡组存在满足条件的卡，并登记将卡组1张卡加入手卡。
function c19182751.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1只机械族调整，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19182751.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次操作信息为从卡组将1张卡加入手卡，供连锁判定等系统使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：从卡组选1只机械族调整加入手卡，并向对方展示。
function c19182751.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的机械族调整（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c19182751.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
