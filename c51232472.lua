--暗黒界の策士 グリン
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
function c51232472.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51232472,0))  --"把场上1张魔法或者陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c51232472.descon)
	e1:SetTarget(c51232472.destg)
	e1:SetOperation(c51232472.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡从前置位置（手卡）因效果送入墓地
function c51232472.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 过滤函数：判断目标是否为魔法或陷阱类型
function c51232472.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理时选择目标：选择场上1张魔法或陷阱卡作为对象
function c51232472.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51232472.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c51232472.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：对选中的卡进行破坏
function c51232472.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
