--ワーム・アポカリプス
-- 效果：
-- 反转：场上的1张魔法或者陷阱卡破坏。
function c88650530.initial_effect(c)
	-- 反转：场上的1张魔法或者陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c88650530.destg)
	e1:SetOperation(c88650530.desop)
	c:RegisterEffect(e1)
end
-- 过滤魔法与陷阱卡的条件函数
function c88650530.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标选择与处理信息设置（选择场上1张魔法或陷阱卡作为对象）
function c88650530.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c88650530.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上合计1张满足条件的魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c88650530.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，包含破坏分类和被选择的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，破坏作为对象的卡
function c88650530.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
