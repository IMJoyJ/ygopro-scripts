--メタルフォーゼ・シルバード
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽描述】
-- 操纵着白银亚光速喷气机的美丽狙击手。想捕捉到用超常识速度飞驰的她是几乎不可能的事，没有办法能从快如光速时施展的一击中逃脱出去。
function c7868571.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c7868571.target)
	e1:SetOperation(c7868571.operation)
	c:RegisterEffect(e1)
end
-- 过滤可作为破坏对象的卡片（必须是表侧表示，且破坏后能腾出魔陷区域或本身有空余魔陷区域，且卡组有可盖放的「炼装」魔陷）
function c7868571.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 检查将该卡破坏后自己场上是否有可用于盖放魔陷的空余区域，且卡组中存在可盖放的「炼装」魔法·陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c7868571.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤卡组中可盖放的「炼装」魔法·陷阱卡
function c7868571.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 灵摆效果的发动准备与目标选择（检查是否存在可破坏的卡，并进行取对象和设置破坏操作信息）
function c7868571.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c7868571.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 效果发动时的可行性检查，判断自己场上是否存在除这张卡以外的表侧表示卡片作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(c7868571.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张除这张卡以外的表侧表示卡片作为对象
	local g=Duel.SelectTarget(tp,c7868571.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置效果处理的操作信息为“破坏选中的卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果的实际处理（破坏对象卡，并从卡组盖放「炼装」魔陷）
function c7868571.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的破坏对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查自身和对象卡是否仍适用此效果，并执行破坏，确认破坏成功
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足条件的「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c7868571.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的「炼装」魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
