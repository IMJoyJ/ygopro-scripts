--魔装戦士 ハイドロータス
-- 效果：
-- ①：这张卡反转的场合，以对方场上1张魔法·陷阱卡为对象发动。那张卡破坏。
function c82176812.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1张魔法·陷阱卡为对象发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c82176812.destg)
	e1:SetOperation(c82176812.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：是否为魔法卡或陷阱卡
function c82176812.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标选择与信息设置：验证对象合法性，选择对方场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function c82176812.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c82176812.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张符合过滤条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c82176812.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表示将要破坏所选择的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取对象卡，若其仍与效果有关联，则将其破坏
function c82176812.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
