--機限爆弾
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「机皇」的怪兽和对方场上存在的1张卡发动。选择的卡破坏。
function c41475424.initial_effect(c)
	-- 效果原文内容：选择自己场上表侧表示存在的1只名字带有「机皇」的怪兽和对方场上存在的1张卡发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c41475424.target)
	e1:SetOperation(c41475424.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出场上表侧表示且名字带有「机皇」的怪兽
function c41475424.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 效果作用：判断是否满足发动条件，即自己场上存在1只名字带有「机皇」的怪兽，对方场上存在1张卡
function c41475424.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：判断自己场上是否存在名字带有「机皇」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c41475424.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：判断对方场上是否存在1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择自己场上表侧表示存在的1只名字带有「机皇」的怪兽
	local g1=Duel.SelectTarget(tp,c41475424.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择对方场上存在的1张卡
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 效果作用：设置本次连锁的操作信息，指定破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果作用：处理效果，获取连锁中的对象卡组并进行破坏
function c41475424.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中被指定的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 效果作用：以效果为原因破坏目标卡组中的卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
