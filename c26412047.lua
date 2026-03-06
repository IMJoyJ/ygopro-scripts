--ハンマーシュート
-- 效果：
-- ①：场上的攻击表示怪兽之内攻击力最高的1只怪兽破坏。
function c26412047.initial_effect(c)
	-- 效果原文内容：①：场上的攻击表示怪兽之内攻击力最高的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26412047.target)
	e1:SetOperation(c26412047.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选攻击表示的怪兽
function c26412047.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果作用：设置连锁处理目标为攻击力最高的怪兽
function c26412047.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26412047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取场上所有攻击表示怪兽
	local g=Duel.GetMatchingGroup(c26412047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 效果作用：设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果作用：处理破坏效果
function c26412047.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取场上所有攻击表示怪兽
	local g=Duel.GetMatchingGroup(c26412047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 效果作用：提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 效果作用：显示选中的卡被选为对象
			Duel.HintSelection(sg)
			-- 效果作用：将选中的卡破坏
			Duel.Destroy(sg,REASON_EFFECT)
		-- 效果作用：直接破坏攻击力最高的怪兽
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
