--静寂虫
-- 效果：
-- 这张卡召唤·反转召唤成功的场合变成守备表示。只要这张卡在场上表侧表示存在，永续魔法·永续陷阱卡的效果无效。
function c40867519.initial_effect(c)
	-- 这张卡召唤·反转召唤成功的场合变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40867519,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40867519.postg)
	e1:SetOperation(c40867519.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，永续魔法·永续陷阱卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c40867519.distarget)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，永续魔法·永续陷阱卡的效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c40867519.disop)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上表侧表示存在，永续魔法·永续陷阱卡的效果无效。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c40867519.distarget)
	c:RegisterEffect(e5)
end
-- 检查自身是否处于攻击表示，用于确定效果是否可以发动。
function c40867519.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置连锁处理时的操作信息，表明将要改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 将自身从攻击表示变为守备表示。
function c40867519.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 执行将卡片变为守备表示的操作。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判断目标卡片是否为永续魔法或永续陷阱且不是自身。
function c40867519.distarget(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_CONTINUOUS)
end
-- 当连锁处理时，若触发位置为魔法陷阱区域且为永续类型，则使该效果无效。
function c40867519.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置信息。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_CONTINUOUS) then
		-- 使指定连锁的效果无效。
		Duel.NegateEffect(ev)
	end
end
