--ドラコニアの翼竜騎兵
-- 效果：
-- ←7 【灵摆】 7→
-- ①：1回合1次，自己的通常怪兽给与对方战斗伤害时，以场上1张卡为对象才能发动。那张卡破坏。
-- 【怪兽描述】
-- 龙人族国家德拉科尼亚帝国所拥有的龙骑士团空兵部队。有传闻说是为了对空中都市国家苏鲁伯这个中立国进行入侵而结成，使得周边国家对此加强警戒。
function c68182934.initial_effect(c)
	-- 为卡片注册灵摆怪兽的专属属性与规则（如灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的通常怪兽给与对方战斗伤害时，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c68182934.descon)
	e2:SetTarget(c68182934.destg)
	e2:SetOperation(c68182934.desop)
	c:RegisterEffect(e2)
end
-- 判定发动条件：给与对方战斗伤害的怪兽是自己场上的通常怪兽
function c68182934.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsType(TYPE_NORMAL)
end
-- 效果发动的目标选择与判定：确认场上存在可选择的对象，并让玩家选择1张卡作为对象
function c68182934.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段判定场上是否存在至少1张可以作为对象破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为该效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的预报信息，表明此效果将破坏所选的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若作为对象的卡依然合法存在，则将其破坏
function c68182934.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
