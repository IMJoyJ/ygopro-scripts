--メタル・シューター
-- 效果：
-- 这张卡召唤成功时，给这张卡放置2个指示物。这个效果每放置有1个指示物，这张卡的攻击力上升800。这张卡被其他卡的效果破坏的场合，把这张卡的1个指示物取除作代替。
function c7200041.initial_effect(c)
	c:EnableCounterPermit(0x26)
	-- 这张卡召唤成功时，给这张卡放置2个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7200041,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c7200041.addct)
	e1:SetOperation(c7200041.addc)
	c:RegisterEffect(e1)
	-- 这个效果每放置有1个指示物，这张卡的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c7200041.attackup)
	c:RegisterEffect(e2)
	-- 这张卡被其他卡的效果破坏的场合，把这张卡的1个指示物取除作代替。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c7200041.reptg)
	c:RegisterEffect(e3)
end
-- 放置指示物效果的Target函数，用于设置效果处理的操作信息
function c7200041.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x26)
end
-- 放置指示物效果的Operation函数，若此卡仍在场则为其放置2个指示物
function c7200041.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x26,2)
	end
end
-- 计算攻击力上升值的函数，返回此卡上的指示物数量乘以800
function c7200041.attackup(e,c)
	return c:GetCounter(0x26)*800
end
-- 代替破坏效果的Target函数，检测自身是否因效果被破坏且能移除1个指示物作为代替
function c7200041.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_EFFECT)
		and e:GetHandler():IsCanRemoveCounter(tp,0x26,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x26,1,REASON_EFFECT)
	return true
end
