--メタルフォーゼ・スティエレン
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽描述】
-- 当隐藏于黑铁机身中的灵魂觉醒之时，钢铁将升华化作秘金属，成为人机一体的勇士。令刻于其身的魂钢燃烧起来吧！——炼装融合！！
function c60473572.initial_effect(c)
	-- 初始化灵摆怪兽属性，注册灵摆召唤和灵摆卡的发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c60473572.target)
	e1:SetOperation(c60473572.operation)
	c:RegisterEffect(e1)
end
-- 过滤自身场上可作为破坏对象的表侧表示卡片（需保证破坏后有空余魔陷格且卡组有可盖放的炼装魔陷）
function c60473572.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 检查将该卡破坏后是否有可用的魔法与陷阱区域，并且卡组中存在可盖放的「炼装」魔法·陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c60473572.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤卡组中可盖放的「炼装」魔法·陷阱卡
function c60473572.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 灵摆效果的发动准备与目标选择
function c60473572.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c60473572.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 在发动时，检查场上是否存在除这张卡以外的、满足条件的表侧表示卡片作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c60473572.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张除这张卡以外的表侧表示卡片作为效果对象
	local g=Duel.SelectTarget(tp,c60473572.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置效果处理的操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果的实际处理逻辑
function c60473572.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查此卡与对象卡是否仍适用效果，并破坏该对象卡
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c60473572.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的「炼装」魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
