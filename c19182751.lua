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
-- 在怪兽被通常召唤成功时，将效果注册到自身上
function c19182751.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 在结束阶段时发动，从卡组把1只机械族调整加入手卡。
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
-- 过滤函数，用于筛选满足条件的卡片：种族为机械族、类型为调整、可以送去手卡
function c19182751.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 设置连锁处理信息，确定效果处理时会将1张卡从卡组送去手卡
function c19182751.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19182751.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示效果处理时会将1张卡从卡组送去手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示玩家选择要加入手牌的卡，并执行将卡送去手牌和确认卡片的操作
function c19182751.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c19182751.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送去手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
