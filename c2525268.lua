--魔導騎士 ディフェンダー
-- 效果：
-- ①：这张卡召唤的场合发动。给这张卡放置1个魔力指示物（最多1个）。
-- ②：1回合1次，场上的魔法师族怪兽被破坏的场合，可以作为代替把那个数量的自己场上的魔力指示物取除。
function c2525268.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,1)
	-- ①：这张卡召唤的场合发动。给这张卡放置1个魔力指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2525268,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c2525268.addct)
	e1:SetOperation(c2525268.addc)
	c:RegisterEffect(e1)
	-- ②：1回合1次，场上的魔法师族怪兽被破坏的场合，可以作为代替把那个数量的自己场上的魔力指示物取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c2525268.destg)
	e2:SetValue(c2525268.value)
	e2:SetOperation(c2525268.desop)
	c:RegisterEffect(e2)
end
c2525268.mentioned_counter={
	[0x1]=true,
}
-- 召唤成功时触发的目标函数：该效果必发无需检查发动条件，并设置本次处理要放置1个魔力指示物的操作信息。
function c2525268.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为放置1个魔力指示物（指示物效果分类）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理：确认这张卡仍与该效果关联后，给这张卡放置1个魔力指示物。
function c2525268.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 破坏代替的筛选条件：被破坏的卡是场上表侧表示的魔法师族怪兽，因战斗或效果被破坏，且不是已被其他效果代替破坏的。
function c2525268.dfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的目标函数：统计本次被破坏且满足条件的魔法师族怪兽数量并记录到Label，chk==0时检查是否存在这类怪兽且自己场上的魔力指示物足够取除该数量，否则询问玩家是否适用代替破坏。
function c2525268.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c2525268.dfilter,nil)
		e:SetLabel(count)
		-- 发动条件检查：存在满足条件的被破坏的魔法师族怪兽，且自己场上能以代价取除对应数量的魔力指示物。
		return count>0 and Duel.IsCanRemoveCounter(tp,1,0,0x1,count,REASON_COST)
	end
	-- 询问玩家是否适用这个代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的适用范围判断：被破坏的卡是场上表侧表示的魔法师族怪兽。
function c2525268.value(e,c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER)
end
-- 代替破坏的处理：取出之前记录的需代替数量，从自己场上取除该数量的魔力指示物作为破坏的代替。
function c2525268.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	-- 从自己场上取除count个魔力指示物，代替那些魔法师族怪兽的破坏。
	Duel.RemoveCounter(tp,1,0,0x1,count,REASON_COST)
end
