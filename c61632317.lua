--ダーク・スプロケッター
-- 效果：
-- 这张卡被暗属性的同调怪兽的同调召唤使用送去墓地的场合，可以把场上表侧表示存在的1张魔法或者陷阱卡破坏。
function c61632317.initial_effect(c)
	-- 这张卡被暗属性的同调怪兽的同调召唤使用送去墓地的场合，可以把场上表侧表示存在的1张魔法或者陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61632317,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c61632317.descon)
	e1:SetTarget(c61632317.destg)
	e1:SetOperation(c61632317.desop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：这张卡作为同调素材送去墓地，且该同调怪兽属性为暗属性
function c61632317.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤条件：场上表侧表示的魔法或陷阱卡
function c61632317.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的发动准备：进行对象选择并设置破坏的操作信息
function c61632317.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c61632317.filter(chkc) end
	-- 在发动阶段（chk==0）判定场上是否存在至少1张符合条件的表侧表示魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c61632317.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c61632317.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏所选的对象卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取对象卡片，若其仍适用则将其破坏
function c61632317.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
