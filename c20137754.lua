--流星方界器デューザ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「方界」卡送去墓地。
-- ②：1回合1次，这张卡表侧表示存在的状态，怪兽被送去自己墓地的回合才能发动。这张卡的攻击力直到回合结束时上升自己墓地的怪兽种类×200。这个效果在对方回合也能发动。
function c20137754.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「方界」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20137754,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c20137754.tgtg)
	e1:SetOperation(c20137754.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡表侧表示存在的状态，怪兽被送去自己墓地的回合才能发动。这张卡的攻击力直到回合结束时上升自己墓地的怪兽种类×200。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20137754,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	e3:SetCondition(c20137754.atkcon)
	e3:SetTarget(c20137754.atktg)
	e3:SetOperation(c20137754.atkop)
	c:RegisterEffect(e3)
	-- 当怪兽被送去墓地时，记录该卡为「流星方界器 天尘」的效果触发条件。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c20137754.regcon)
	e4:SetOperation(c20137754.regop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选卡组中可送去墓地的「方界」卡。
function c20137754.tgfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToGrave()
end
-- 效果处理时，检查卡组中是否存在满足条件的「方界」卡。
function c20137754.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「方界」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c20137754.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，提示将从卡组选择1张「方界」卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示玩家选择卡组中的「方界」卡并将其送去墓地。
function c20137754.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张「方界」卡。
	local g=Duel.SelectMatchingCard(tp,c20137754.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断是否满足效果发动条件，即该回合有怪兽被送去墓地。
function c20137754.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(20137754)>0
		-- 限制效果只能在伤害计算前发动。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理时，检查墓地中是否存在怪兽。
function c20137754.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在怪兽。
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)>0 end
end
-- 效果处理函数，计算墓地中怪兽数量并提升攻击力。
function c20137754.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取墓地中所有怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local val=g:GetClassCount(Card.GetCode)*200
	if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
		-- 将攻击力提升效果注册到自身。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，用于筛选被送去墓地的怪兽。
function c20137754.rfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_RETURN)
end
-- 判断是否有怪兽被送去墓地。
function c20137754.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20137754.rfilter,1,nil,tp)
end
-- 为自身注册标记，表示该回合有怪兽被送去墓地。
function c20137754.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20137754,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
