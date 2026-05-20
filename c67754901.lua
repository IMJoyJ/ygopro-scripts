--オッドアイズ・ミラージュ・ドラゴン
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，自己场上的表侧表示的「异色眼」灵摆怪兽被战斗·效果破坏的场合才能发动。选自己的灵摆区域1张卡破坏，从自己的额外卡组选「异色眼幻象龙」以外的1只表侧表示的「异色眼」灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 「异色眼幻象龙」的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆区域有「异色眼」卡存在的场合，以自己场上1只「异色眼」怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c67754901.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 「异色眼幻象龙」的怪兽效果1回合只能使用1次。①：自己的灵摆区域有「异色眼」卡存在的场合，以自己场上1只「异色眼」怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67754901,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,67754901)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c67754901.indcon)
	e1:SetTarget(c67754901.indtg)
	e1:SetOperation(c67754901.indop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的表侧表示的「异色眼」灵摆怪兽被战斗·效果破坏的场合才能发动。选自己的灵摆区域1张卡破坏，从自己的额外卡组选「异色眼幻象龙」以外的1只表侧表示的「异色眼」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c67754901.pencon)
	e2:SetTarget(c67754901.pentg)
	e2:SetOperation(c67754901.penop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「异色眼」怪兽
function c67754901.indfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99)
end
-- 怪兽效果的发动条件：检查自己的灵摆区域是否存在「异色眼」卡
function c67754901.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在至少1张「异色眼」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x99)
end
-- 怪兽效果的对象选择与发动准备
function c67754901.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c67754901.indfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示「异色眼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c67754901.indfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「异色眼」怪兽作为效果对象
	Duel.SelectTarget(tp,c67754901.indfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 怪兽效果的实际处理：为目标怪兽适用“本回合只有1次不会被战斗·效果破坏”的效果
function c67754901.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽在这个回合只有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(c67754901.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤破坏原因：仅在因战斗或效果破坏时适用该代替效果
function c67754901.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 过滤条件：自己场上原本表侧表示的「异色眼」灵摆怪兽因战斗或效果被破坏
function c67754901.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 过滤条件：额外卡组中「异色眼幻象龙」以外的表侧表示的「异色眼」灵摆怪兽，且不能是无法放置的卡
function c67754901.penfilter(c)
	return c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsCode(67754901) and not c:IsForbidden()
end
-- 灵摆效果的发动条件：自己场上的表侧表示「异色眼」灵摆怪兽被破坏
function c67754901.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c67754901.cfilter,1,nil,tp)
end
-- 灵摆效果的发动准备：检查灵摆区域是否有卡可破坏，以及额外卡组是否有可放置的怪兽
function c67754901.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否存在至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
		-- 检查自己的额外卡组是否存在满足条件的表侧表示「异色眼」灵摆怪兽
		and Duel.IsExistingMatchingCard(c67754901.penfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置效果处理信息：准备破坏自己灵摆区域的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果的实际处理：破坏自己灵摆区域的1张卡，并将额外卡组的1只「异色眼」灵摆怪兽放置到灵摆区域
function c67754901.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的灵摆区域选择1张卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0):Select(tp,1,1,nil)
	if g:GetCount()>0 then
		-- 显式地在场上框选并展示被选中的灵摆区域卡片
		Duel.HintSelection(g)
		-- 破坏选中的卡，若破坏失败则终止后续效果处理
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end
		-- 提示玩家选择要放置到场上的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从额外卡组选择1只满足条件的表侧表示「异色眼」灵摆怪兽
		local sg=Duel.SelectMatchingCard(tp,c67754901.penfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			-- 将选中的怪兽在自己的灵摆区域表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
