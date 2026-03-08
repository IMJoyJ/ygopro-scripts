--シンクロ・クラッカー
-- 效果：
-- ①：以自己场上1只同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，持有那只同调怪兽的原本攻击力以下的攻击力的对方场上的表侧表示怪兽全部破坏。
function c41097056.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只同调怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41097056.target)
	e1:SetOperation(c41097056.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：筛选满足条件的同调怪兽，该怪兽需表侧表示、类型为同调、能回到额外卡组，并且对方场上存在攻击力低于该怪兽原本攻击力的表侧表示怪兽。
function c41097056.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
		-- 规则层面作用：检查对方场上是否存在攻击力低于指定攻击力的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c41097056.desfilter,tp,0,LOCATION_MZONE,1,nil,math.max(0,c:GetTextAttack()))
end
-- 规则层面作用：筛选攻击力低于指定值的表侧表示怪兽。
function c41097056.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果原文内容：那只怪兽回到持有者的额外卡组，持有那只同调怪兽的原本攻击力以下的攻击力的对方场上的表侧表示怪兽全部破坏。
function c41097056.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41097056.filter(chkc,tp) end
	-- 规则层面作用：检查自己场上是否存在满足filter条件的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c41097056.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 规则层面作用：向玩家提示选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面作用：选择满足filter条件的1只怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c41097056.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 规则层面作用：获取对方场上所有攻击力低于目标怪兽原本攻击力的表侧表示怪兽。
	local g2=Duel.GetMatchingGroup(c41097056.desfilter,tp,0,LOCATION_MZONE,nil,math.max(0,g1:GetFirst():GetTextAttack()))
	-- 规则层面作用：设置效果操作信息，表示将目标怪兽送回额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g1,1,0,0)
	-- 规则层面作用：设置效果操作信息，表示将符合条件的对方怪兽破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,g2:GetCount(),0,0)
end
-- 规则层面作用：处理效果发动后的操作，包括将目标怪兽送回额外卡组并破坏对方符合条件的怪兽。
function c41097056.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	-- 规则层面作用：判断目标怪兽是否仍然存在于场上且能被效果处理，然后将其送回额外卡组。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 规则层面作用：获取对方场上所有攻击力低于目标怪兽原本攻击力的表侧表示怪兽。
		local g=Duel.GetMatchingGroup(c41097056.desfilter,tp,0,LOCATION_MZONE,nil,atk)
		-- 规则层面作用：将符合条件的对方怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
