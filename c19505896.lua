--ウィード
-- 效果：
-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的这张卡以外的1只植物族怪兽破坏。
function c19505896.initial_effect(c)
	-- 效果原文内容：场上表侧表示存在的这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的这张卡以外的1只植物族怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c19505896.desreptg)
	e1:SetOperation(c19505896.desrepop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义了可用于代替破坏的卡片过滤条件，必须是表侧表示、植物族、可被破坏且未被预定破坏的怪兽。
function c19505896.repfilter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 规则层面作用：判断是否满足发动代替破坏效果的条件，即当前卡未被代替破坏，并且场上存在符合条件的植物族怪兽。
function c19505896.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 规则层面作用：检查场上是否存在至少一张满足代替破坏条件的植物族怪兽。
		and Duel.IsExistingMatchingCard(c19505896.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 规则层面作用：询问玩家是否发动此代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 规则层面作用：提示玩家选择要代替破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 规则层面作用：选择一张满足条件的植物族怪兽作为代替破坏的目标。
		local g=Duel.SelectMatchingCard(tp,c19505896.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 规则层面作用：执行代替破坏效果，将选定的怪兽从场上破坏。
function c19505896.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 规则层面作用：以效果和代替破坏的原因将选定的怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
