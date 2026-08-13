--隠されし機殻
-- 效果：
-- 「隐藏的机壳」在1回合只能发动1张。
-- ①：从自己的额外卡组把最多3只表侧表示的「机壳」灵摆怪兽加入手卡。
function c4450854.initial_effect(c)
	-- 「隐藏的机壳」在1回合只能发动1张。①：从自己的额外卡组把最多3只表侧表示的「机壳」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4450854+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c4450854.target)
	e1:SetOperation(c4450854.activate)
	c:RegisterEffect(e1)
end
-- 筛选额外卡组中表侧表示、字段为「机壳」的灵摆怪兽，且不存在“不能加入手卡”的限制，满足可被加入手卡的条件。
function c4450854.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 作为发动时的目标判定与操作信息设定：检查额外卡组是否存在符合条件的卡，若存在则登记本次效果将额外卡组的卡加入手卡的操作类别，供后续连锁判定使用。
function c4450854.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非效果处理时的发动条件检查：自己额外卡组中存在至少1张满足filter的卡时，效果才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4450854.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置当前连锁的操作信息：把本次效果登记为“从自己额外卡组将卡加入手卡”，预计处理1张（实际可选1~3张），位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时的实际操作：从自己额外卡组选择1~3张满足filter的卡，将其加入持有者手卡，并向对方展示这些卡。
function c4450854.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示，引导其进行卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组选择1~3张满足filter的卡（效果处理时选择，不取对象），作为将要加入手卡的卡。
	local g=Duel.SelectMatchingCard(tp,c4450854.filter,tp,LOCATION_EXTRA,0,1,3,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，送入原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示被加入手卡的卡牌，用于确认这些卡被实际加入了手卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
