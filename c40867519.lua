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
	-- 永续魔法·永续陷阱卡的效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c40867519.disop)
	c:RegisterEffect(e4)
	-- 永续魔法·永续陷阱卡的效果无效。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c40867519.distarget)
	c:RegisterEffect(e5)
end
-- 诱发效果的发动判定：召唤成功时，若自身为攻击表示则满足发动条件，并登记将自身改变表示形式的操作信息。
function c40867519.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置操作信息：当前连锁将执行改变表示形式的处理，对象为效果持有者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理：若自身仍处于表侧攻击表示且与该效果仍有关联，则将其变更为表侧守备表示。
function c40867519.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将“静寂虫”的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 筛选要被无效效果的卡：不是静寂虫自身，且为永续魔法或永续陷阱卡（TYPE_CONTINUOUS）。
function c40867519.distarget(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_CONTINUOUS)
end
-- 连锁处理时进行拦截：若连锁发生在魔法与陷阱区域且该连锁效果为永续魔法/永续陷阱卡的效果，则将其无效。
function c40867519.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发生位置，以判断是否来自魔法与陷阱区域。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_CONTINUOUS) then
		-- 使该连锁的效果无效化。
		Duel.NegateEffect(ev)
	end
end
