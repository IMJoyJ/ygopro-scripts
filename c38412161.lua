--霊塞術師 チョウサイ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把墓地的魔法·陷阱卡的效果发动。
-- ②：这张卡从场上送去墓地的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡除外。
function c38412161.initial_effect(c)
	-- 效果原文内容：只要这张卡在怪兽区域存在，双方不能把墓地的魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c38412161.actlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡从场上送去墓地的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38412161,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c38412161.remcon)
	e2:SetTarget(c38412161.remtg)
	e2:SetOperation(c38412161.remop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否为墓地的魔法或陷阱卡的效果发动
function c38412161.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 规则层面作用：判断此卡是否从场上送去墓地
function c38412161.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面作用：筛选对方墓地的魔法或陷阱卡
function c38412161.remfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 规则层面作用：选择对方墓地的一张魔法或陷阱卡作为除外对象
function c38412161.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c38412161.remfilter(chkc) end
	-- 规则层面作用：检查是否有满足条件的对方墓地魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c38412161.remfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 规则层面作用：向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：选择满足条件的对方墓地魔法或陷阱卡
	local g=Duel.SelectTarget(tp,c38412161.remfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 规则层面作用：设置本次效果操作信息，表示将要除外一张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 规则层面作用：执行将选中的卡除外的操作
function c38412161.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：以正面表示的形式将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
