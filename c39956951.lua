--封魔一閃
-- 效果：
-- 对方场上的怪兽卡区域全部有怪兽存在的场合才能发动。对方场上存在的全部怪兽破坏。
function c39956951.initial_effect(c)
	-- 对方场上的怪兽卡区域全部有怪兽存在的场合才能发动。对方场上存在的全部怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c39956951.condition)
	e1:SetTarget(c39956951.target)
	e1:SetOperation(c39956951.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片位于对方的主要怪兽区（序号0~4，不含额外怪兽区），用于统计对方怪兽卡区域是否全部被怪兽占据。
function c39956951.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件函数：统计对方场上主要怪兽区中满足cfilter条件的怪兽数量，若达到5张（即5个主要怪兽区域全部有怪兽存在）才允许发动。
function c39956951.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计对方场上主要怪兽区中满足cfilter条件的怪兽数量是否不少于5张，以此判定对方场上怪兽卡区域是否全部有怪兽。
	return Duel.GetMatchingGroupCount(c39956951.cfilter,tp,0,LOCATION_MZONE,nil)>=5
end
-- 发动时处理函数：先确认对方场上主要怪兽区存在怪兽，再获取对方场上所有主要怪兽区的怪兽作为破坏对象，并向系统设置本次效果的破坏信息。
function c39956951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定阶段（chk==0）检查对方场上主要怪兽区是否存在至少1只怪兽；由于条件已保证5格全满，此检查用于确保有可被破坏的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上主要怪兽区当前存在的全部怪兽作为效果处理时确定的不取对象破坏目标。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：将上一步取得的全部怪兽登记为此次破坏效果的目标，数量为怪兽总数，用于适配星尘龙等对破坏效果的应答。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：在效果结算时重新获取对方场上主要怪兽区的全部怪兽，并将其全部破坏。
function c39956951.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果结算时再次获取对方场上主要怪兽区当前存在的全部怪兽（防止延迟处理期间怪兽发生变化）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽以效果（REASON_EFFECT）的原因破坏并送去墓地。
	Duel.Destroy(sg,REASON_EFFECT)
end
