--ブラッド・マジシャン－煉獄の魔術師－
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置魔力指示物。可以把这张卡放置的魔力指示物任意数量取除，持有取除数量×700的数值以下的攻击力的场上表侧表示存在的1只怪兽破坏。
function c21051146.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 可以把这张卡放置的魔力指示物任意数量取除，持有取除数量×700的数值以下的攻击力的场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c21051146.acop)
	c:RegisterEffect(e1)
	-- 破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21051146,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c21051146.destg)
	e2:SetOperation(c21051146.desop)
	c:RegisterEffect(e2)
end
-- 当有魔法卡发动时，若此卡在连锁中存在，则给此卡放置1个魔力指示物
function c21051146.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 判断目标怪兽是否满足破坏条件（攻击力不超过取除指示物数量×700）
function c21051146.filter(c,cc,tp)
	local ct=math.ceil(c:GetAttack()/700)
	if ct==0 then ct=1 end
	return c:IsFaceup() and cc:IsCanRemoveCounter(tp,0x1,ct,REASON_COST)
end
-- 选择满足条件的怪兽作为破坏对象，并扣除相应数量的魔力指示物
function c21051146.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c21051146.filter(chkc,e:GetHandler(),tp) end
	-- 判断是否存在满足条件的怪兽作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(c21051146.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c21051146.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler(),tp)
	local ct=math.ceil(g:GetFirst():GetAttack()/700)
	if ct==0 then ct=1 end
	e:GetHandler():RemoveCounter(tp,0x1,ct,REASON_COST)
	-- 设置本次连锁操作为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作，将选中的怪兽破坏
function c21051146.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
