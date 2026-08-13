--ウィード
-- 效果：
-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的这张卡以外的1只植物族怪兽破坏。
function c19505896.initial_effect(c)
	-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的这张卡以外的1只植物族怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c19505896.desreptg)
	e1:SetOperation(c19505896.desrepop)
	c:RegisterEffect(e1)
end
-- 筛选满足代替破坏条件的怪兽：必须是表侧表示、植物族、可被该效果破坏且未被预定破坏的怪兽。
function c19505896.repfilter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代破效果的发动的可行条件判定：本卡不是因代替破坏而将要被破坏，并且自己场上存在其他满足条件的植物族怪兽。
function c19505896.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在1张满足repfilter条件的植物族怪兽，检索范围不包括这张卡自身。
		and Duel.IsExistingMatchingCard(c19505896.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问控制者是否发动代替破坏效果（使用编号96的提示文字）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 发送“请选择要代替破坏的卡”的选择提示，供后续选择卡片时显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己场上选择1张满足repfilter条件的其他植物族怪兽，作为代替破坏的候选卡。
		local g=Duel.SelectMatchingCard(tp,c19505896.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果处理：取出选定的代替破坏怪兽，解除其预定破坏状态，并将其破坏。
function c19505896.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏并带有代替破坏原因的方式，将选定的植物族怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
