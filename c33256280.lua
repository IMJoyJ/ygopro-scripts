--メタルフォーゼ・ゴルドライバー
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽描述】
-- 闪耀着黄金车身的光芒，以豪爽的漂移跑法横扫敌军。尽管经常都很夸张地出现侧滑失控，但本人坚定立场地表示那就是必杀技。
function c33256280.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，包括灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c33256280.target)
	e1:SetOperation(c33256280.operation)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否满足破坏条件，包括表侧表示、灵摆区有空位、卡组存在符合条件的「炼装」魔法·陷阱卡
function c33256280.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 检查目标怪兽所在玩家的灵摆区是否有空位，并确认卡组中存在符合条件的「炼装」魔法·陷阱卡
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c33256280.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤函数，用于筛选卡组中满足「炼装」属性、魔法·陷阱类型且可以盖放的卡片
function c33256280.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 设置效果的目标选择函数，用于选择满足条件的场上怪兽作为破坏对象
function c33256280.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c33256280.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件，即场上存在满足破坏条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c33256280.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的场上怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c33256280.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置连锁操作信息，标记本次效果将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果的处理函数，执行破坏和盖放操作
function c33256280.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认效果处理器和目标怪兽均有效，并执行破坏操作
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择一张符合条件的「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c33256280.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
