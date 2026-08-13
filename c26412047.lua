--ハンマーシュート
-- 效果：
-- ①：场上的攻击表示怪兽之内攻击力最高的1只怪兽破坏。
function c26412047.initial_effect(c)
	-- ①：场上的攻击表示怪兽之内攻击力最高的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26412047.target)
	e1:SetOperation(c26412047.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，筛选出场上表侧攻击表示的怪兽。
function c26412047.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 发动时的目标判断与信息设置：确认存在符合条件的怪兽，并预先检索出攻击力最高的1只怪兽，将破坏信息写入连锁操作。
function c26412047.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：场上是否存在至少1只表侧攻击表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c26412047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上所有表侧攻击表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c26412047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 设置本连锁的操作信息，宣告将破坏攻击力最高的1只怪兽（目标数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理：再次取得场上所有表侧攻击表示怪兽，选出攻击力最高的怪兽；若并列则由玩家选择其中1只破坏，否则直接破坏。
function c26412047.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得场上所有表侧攻击表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c26412047.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 当攻击力最高的怪兽有复数只时，提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 显示被选中卡的动画，并将其记录为被选择对象。
			Duel.HintSelection(sg)
			-- 将玩家选择的怪兽以效果原因破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		-- 攻击力最高的怪兽只有1只时，直接将其破坏。
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
