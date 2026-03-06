--閃刀術式－ジャミングウェーブ
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上盖放的1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，自己墓地有魔法卡3张以上存在的场合，可以选场上1只怪兽破坏。
function c25955749.initial_effect(c)
	-- 效果原文内容：①：自己的主要怪兽区域没有怪兽存在的场合，以场上盖放的1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，自己墓地有魔法卡3张以上存在的场合，可以选场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c25955749.condition)
	e1:SetTarget(c25955749.target)
	e1:SetOperation(c25955749.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查目标怪兽是否在主要怪兽区域（序列小于5）
function c25955749.cfilter(c)
	return c:GetSequence()<5
end
-- 效果作用：判断自己主要怪兽区域是否没有怪兽存在
function c25955749.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己主要怪兽区域是否没有怪兽存在
	return not Duel.IsExistingMatchingCard(c25955749.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：过滤场上盖放的魔法·陷阱卡
function c25955749.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：设置效果目标，选择场上盖放的魔法·陷阱卡
function c25955749.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c25955749.filter(chkc) and chkc~=e:GetHandler() end
	-- 效果作用：检查是否存在满足条件的魔法·陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c25955749.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上盖放的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c25955749.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果作用：设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：处理效果发动后的破坏操作
function c25955749.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认目标卡有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 效果作用：获取场上所有怪兽
		local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 效果作用：判断墓地魔法卡数量是否大于等于3并询问是否破坏怪兽
		if dg:GetCount()>0 and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 and Duel.SelectYesNo(tp,aux.Stringid(25955749,0)) then  --"是否选怪兽卡破坏？"
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,1,nil)
			-- 效果作用：显示选中卡的动画效果
			Duel.HintSelection(sg)
			-- 效果作用：破坏选中的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
