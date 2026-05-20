--エクシーズエフェクト
-- 效果：
-- 自己超量召唤成功时，选择场上存在的1张卡才能发动。选择的卡破坏。
function c58628539.initial_effect(c)
	-- 自己超量召唤成功时，选择场上存在的1张卡才能发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c58628539.condition)
	e1:SetTarget(c58628539.target)
	e1:SetOperation(c58628539.activate)
	c:RegisterEffect(e1)
end
-- 判定是否为自己成功超量召唤1只怪兽的时点
function c58628539.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ) and eg:GetFirst():IsControler(tp)
end
-- 效果发动的对象选择与检测，选择场上存在的1张卡作为对象
function c58628539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 在发动阶段，检查场上是否存在除这张卡以外的、可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给发动效果的玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上存在的1张卡（除这张卡以外）作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果处理信息，表明该连锁的处理分类为破坏，数量为1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理，破坏作为对象的卡
function c58628539.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
