--闇の支配者－ゾーク
-- 效果：
-- 「与暗之支配者的契约」降临。
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子，出现的数目的效果适用。
-- ●1·2：对方场上的怪兽全部破坏。
-- ●3·4·5：选对方场上1只怪兽破坏。
-- ●6：自己场上的怪兽全部破坏。
function c97642679.initial_effect(c)
	-- 登记卡片效果中记有「与暗之支配者的契约」的卡片密码
	aux.AddCodeList(c,96420087)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子，出现的数目的效果适用。 ●1·2：对方场上的怪兽全部破坏。 ●3·4·5：选对方场上1只怪兽破坏。 ●6：自己场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97642679,0))  --"掷骰子"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c97642679.target)
	e1:SetOperation(c97642679.operation)
	c:RegisterEffect(e1)
end
-- 效果目标：设置投骰子与破坏怪兽的操作信息
function c97642679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果分类为投骰子，数量为1次
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 获取对方场上的全部怪兽
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 获取自己场上的全部怪兽
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if g1:GetCount()~=0 and g2:GetCount()~=0 then
		g1:Merge(g2)
		-- 设置当前效果分类为破坏，并根据可能破坏的卡片设置操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	end
end
-- 效果处理：掷1次骰子，并根据出现的数目适用对应的破坏效果
function c97642679.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 掷1次骰子，获取掷出的数目
	local d=Duel.TossDice(tp,1)
	if d==1 or d==2 then
		-- 获取对方场上的全部怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 破坏对方场上的全部怪兽
		Duel.Destroy(g,REASON_EFFECT)
	elseif d==6 then
		-- 获取自己场上的全部怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 破坏自己场上的全部怪兽
		Duel.Destroy(g,REASON_EFFECT)
	elseif d>=3 and d<=5 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方场上的1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		-- 破坏选中的那只对方怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
