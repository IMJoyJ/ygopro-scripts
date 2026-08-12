--テレキアタッカー
-- 效果：
-- 念动力族怪兽被破坏的场合，可以支付500基本分作为代替把这张卡破坏。
function c84847656.initial_effect(c)
	-- 念动力族怪兽被破坏的场合，可以支付500基本分作为代替把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c84847656.destg)
	e1:SetValue(c84847656.value)
	e1:SetOperation(c84847656.desop)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且不是因为代替破坏而将被破坏的念动力族怪兽
function c84847656.dfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsReason(REASON_REPLACE)
end
-- 检查代替破坏效果的条件：被破坏的卡中不包含这张卡自身，且玩家能支付500基本分，且存在满足条件的念动力族怪兽
function c84847656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsContains(e:GetHandler())
		-- 检查玩家是否能支付500基本分，以及被破坏的卡中是否存在满足条件的念动力族怪兽
		and Duel.CheckLPCost(tp,500) and eg:IsExists(c84847656.dfilter,1,nil) end
	-- 询问玩家是否选择发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 支付500基本分
		Duel.PayLPCost(tp,500)
		return true
	else return false end
end
-- 确定适用代替破坏效果的卡，即场上表侧表示的念动力族怪兽
function c84847656.value(e,c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsReason(REASON_REPLACE)
end
-- 执行代替破坏的操作，将这张卡自身破坏
function c84847656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡自身作为代替效果破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
