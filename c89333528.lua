--ジェネクス・ガイア
-- 效果：
-- ①：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「次世代控制员」破坏。
function c89333528.initial_effect(c)
	-- ①：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「次世代控制员」破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c89333528.desreptg)
	e2:SetOperation(c89333528.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、卡名为「次世代控制员」、可被效果破坏且未确定被破坏的怪兽
function c89333528.repfilter(c,e)
	return c:IsFaceup() and c:IsCode(68505803)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的Target函数，检查自身是否在场上表侧表示且不因代替破坏而要被破坏，并检查是否存在可代替破坏的卡
function c89333528.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己场上是否存在至少1只满足代替破坏过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c89333528.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 设置提示信息为选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择自己场上1只满足代替破坏过滤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c89333528.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的Operation函数，获取选中的代替卡并将其破坏
function c89333528.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的代替卡因效果及代替原因破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
