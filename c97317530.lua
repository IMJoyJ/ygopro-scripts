--森の聖獣 カラントーサ
-- 效果：
-- ①：这张卡用兽族怪兽的效果特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c97317530.initial_effect(c)
	-- ①：这张卡用兽族怪兽的效果特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97317530,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c97317530.descon)
	e1:SetTarget(c97317530.destg)
	e1:SetOperation(c97317530.desop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：检查这张卡是否是由兽族怪兽的效果特殊召唤成功
function c97317530.descon(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_BEAST~=0
end
-- 效果发动的目标选择：确认场上是否存在可选择的对象，并进行取对象操作与设置破坏操作信息
function c97317530.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动效果的准备阶段，检查双方场上是否存在至少1张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择场上1张卡作为该效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理为破坏所选的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取对象卡片，若该卡片仍存在于场上（与效果相关联），则将其破坏
function c97317530.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
