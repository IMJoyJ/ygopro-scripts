--EMカード・ガードナー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只表侧守备表示怪兽为对象才能发动。那只怪兽的守备力变成自己场上的全部表侧守备表示怪兽的原本守备力合计数值。
-- 【怪兽效果】
-- ①：这张卡的守备力上升这张卡以外的自己场上的「娱乐伙伴」怪兽的原本守备力的合计数值。
function c37256334.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只表侧守备表示怪兽为对象才能发动。那只怪兽的守备力变成自己场上的全部表侧守备表示怪兽的原本守备力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37256334,0))
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37256334.deftg)
	e1:SetOperation(c37256334.defop)
	c:RegisterEffect(e1)
	-- ①：这张卡的守备力上升这张卡以外的自己场上的「娱乐伙伴」怪兽的原本守备力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c37256334.defval)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断目标怪兽是否为表侧守备表示且当前守备力与指定守备力不同
function c37256334.deffilter1(c,def)
	return c:IsPosition(POS_FACEUP_DEFENSE) and not c:IsDefense(def)
end
-- 效果处理函数：选择一只表侧守备表示的怪兽作为对象，使其守备力变为场上所有表侧守备表示怪兽的原本守备力总和
function c37256334.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上所有表侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
	local def=g:GetSum(Card.GetBaseDefense)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37256334.deffilter1(chkc,def) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c37256334.deffilter1,tp,LOCATION_MZONE,0,1,nil,def) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只表侧守备表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c37256334.deffilter1,tp,LOCATION_MZONE,0,1,1,nil,def)
end
-- 效果发动处理函数：将目标怪兽的守备力设置为场上所有表侧守备表示怪兽的原本守备力总和
function c37256334.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取场上所有表侧守备表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
		local def=g:GetSum(Card.GetBaseDefense)
		-- 创建一个临时效果，将目标怪兽的守备力设置为指定数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(def)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：判断目标怪兽是否为表侧表示且种族为「娱乐伙伴」
function c37256334.deffilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 效果值计算函数：计算场上所有「娱乐伙伴」怪兽的原本守备力总和
function c37256334.defval(e,c)
	-- 获取场上所有「娱乐伙伴」怪兽
	local g=Duel.GetMatchingGroup(c37256334.deffilter2,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetSum(Card.GetBaseDefense)
end
