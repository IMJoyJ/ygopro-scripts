--メタルフォーゼ・ヴォルフレイム
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
-- 【怪兽描述】
-- 拥有赤热魂钢的上级战士。就在与将世界带向终结的红色真龙威胁进行对峙的时候，他得到仿佛彼此呼应而穿越次元出现的光之意志引导，使身披百炼钢甲之术迎来了绽放时刻。
function c69351984.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组选1张「炼装」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c69351984.target)
	e1:SetOperation(c69351984.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上可作为破坏对象的表侧表示卡片
function c69351984.desfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 检查破坏该卡后是否有空余的魔陷区域，且卡组中存在可盖放的「炼装」魔陷
	return Duel.GetSZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c69351984.filter,tp,LOCATION_DECK,0,1,nil,true)
end
-- 过滤卡组中可盖放的「炼装」魔法·陷阱卡
function c69351984.filter(c,ignore)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(ignore)
end
-- 灵摆效果的发动准备与对象选择
function c69351984.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c69351984.desfilter(chkc,tp) and chkc~=e:GetHandler() end
	-- 发动阶段：检查场上是否存在除这张卡以外的、可作为破坏对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c69351984.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张除这张卡以外的表侧表示卡片作为对象
	local g=Duel.SelectTarget(tp,c69351984.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 设置效果处理信息为破坏该卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果的实际处理（破坏并盖放）
function c69351984.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动阶段选择的破坏对象
	local tc=Duel.GetFirstTarget()
	-- 若此卡与对象卡依然适用效果，则将对象卡破坏
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张「炼装」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c69351984.filter,tp,LOCATION_DECK,0,1,1,nil,false)
		if g:GetCount()>0 then
			-- 将选中的卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
