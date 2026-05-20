--チャッチャカアーチャー
-- 效果：
-- 1回合1次，选择场上1张魔法·陷阱卡才能发动。选择的卡破坏。
function c83021423.initial_effect(c)
	-- 1回合1次，选择场上1张魔法·陷阱卡才能发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83021423,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c83021423.destg)
	e1:SetOperation(c83021423.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否是魔法卡或陷阱卡
function c83021423.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动阶段：进行对象选择和操作信息设置
function c83021423.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c83021423.filter(chkc) end
	-- 发动条件检查：判断场上是否存在可作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c83021423.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，要求选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c83021423.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：在连锁处理中将破坏该对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：如果对象卡片仍存在于场上，则将其破坏
function c83021423.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
