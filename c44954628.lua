--巨大戦艦 テトラン
-- 效果：
-- 这张卡召唤时放置3个指示物。这张卡不会被战斗破坏。进行战斗的场合，在伤害步骤结束时取除1个指示物。没有指示物放置的状态进行战斗的场合，伤害步骤结束时这张卡破坏。此外，可以把这张卡的1个指示物取除，破坏场上1张魔法·陷阱卡。这个效果1个回合只能使用1次。
function c44954628.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这张卡召唤时放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44954628,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c44954628.addct)
	e1:SetOperation(c44954628.addc)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 注册一个在伤害步骤结束时触发的效果，用于处理战斗后指示物的移除或卡片的破坏判定。
	aux.EnableBESRemove(c)
	-- 可以把这张卡的1个指示物取除，破坏场上1张魔法·陷阱卡。这个效果1个回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(44954628,3))  --"魔陷破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c44954628.descost2)
	e5:SetTarget(c44954628.destg2)
	e5:SetOperation(c44954628.desop2)
	c:RegisterEffect(e5)
end
-- 设置效果目标为放置3个指示物，用于连锁信息的记录。
function c44954628.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将为卡片放置3个指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 若卡片存在于场上，则为其添加3个指示物。
function c44954628.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
-- 检查是否可以移除1个指示物作为破坏魔法·陷阱卡的代价。
function c44954628.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1f,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_COST)
end
-- 用于筛选场上存在的魔法或陷阱卡。
function c44954628.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置选择目标函数，用于选择场上一张魔法或陷阱卡作为破坏对象。
function c44954628.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c44954628.filter(chkc) end
	-- 检查场上是否存在魔法或陷阱卡作为破坏目标。
	if chk==0 then return Duel.IsExistingTarget(c44954628.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张魔法或陷阱卡作为破坏对象。
	local g=Duel.SelectTarget(tp,c44954628.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示将破坏选定的魔法或陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 若目标卡片存在于场上，则将其破坏。
function c44954628.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选定的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
