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
-- 设置效果处理时的操作信息，用于确定将要放置1个魔力指示物
function c2525268.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为放置魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 执行放置魔力指示物的效果操作
function c2525268.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 过滤满足条件的被破坏的魔法师族怪兽（战斗或效果破坏且非代替破坏）
function c2525268.dfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动代替破坏效果，检查是否有符合条件的怪兽并确认是否能移除相应数量的魔力指示物
function c2525268.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c2525268.dfilter,nil)
		e:SetLabel(count)
		-- 检查玩家是否能移除指定数量的魔力指示物作为代替破坏的代价
		return count>0 and Duel.IsCanRemoveCounter(tp,1,0,0x1,count,REASON_COST)
	end
	-- 询问玩家是否发动该代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判断目标怪兽是否为魔法师族且在场上正面表示
function c2525268.value(e,c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER)
end
-- 执行移除魔力指示物的操作，将指定数量的魔力指示物从场上移除
function c2525268.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	-- 实际执行移除魔力指示物的动作，移除指定数量的指示物作为代替破坏的代价
	Duel.RemoveCounter(tp,1,0,0x1,count,REASON_COST)
end
