--デス・モスキート
-- 效果：
-- 这张卡召唤、特殊召唤成功时，给这张卡放置2个指示物。这个效果每放置有1个指示物，这张卡的攻击力上升500。这张卡被战斗破坏的场合，把这张卡的1个指示物取除作代替。
function c33695750.initial_effect(c)
	c:EnableCounterPermit(0x27)
	-- 这张卡召唤、特殊召唤成功时，给这张卡放置2个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33695750,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33695750.addct)
	e1:SetOperation(c33695750.addc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个效果每放置有1个指示物，这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c33695750.attackup)
	c:RegisterEffect(e3)
	-- 这张卡被战斗破坏的场合，把这张卡的1个指示物取除作代替。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c33695750.reptg)
	c:RegisterEffect(e4)
end
-- 设置连锁操作信息，表明将要放置指示物
function c33695750.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明将要放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x27)
end
-- 将2个指示物放置到自身上
function c33695750.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x27,2)
	end
end
-- 根据指示物数量增加攻击力
function c33695750.attackup(e,c)
	return c:GetCounter(0x27)*500
end
-- 判断是否为战斗破坏且可以移除指示物
function c33695750.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():IsCanRemoveCounter(tp,0x27,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x27,1,REASON_EFFECT)
	return true
end
