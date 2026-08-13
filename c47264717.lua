--シューティング・スター
-- 效果：
-- ①：场上有「星尘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c47264717.initial_effect(c)
	-- ①：场上有「星尘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,0x11e0)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c47264717.condition)
	e1:SetTarget(c47264717.target)
	e1:SetOperation(c47264717.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断卡片是否为「星尘」字段且表侧表示的怪兽。
function c47264717.cfilter(c)
	return c:IsSetCard(0xa3) and c:IsFaceup()
end
-- 效果发动条件：己方或对方场上怪兽区存在至少1只表侧表示的「星尘」怪兽。
function c47264717.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方或对方场上怪兽区是否存在至少1只满足过滤条件（「星尘」字段且表侧表示）的怪兽。
	return Duel.IsExistingMatchingCard(c47264717.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果发动时的取对象处理：确认合法对象，选择场上1张除本卡以外的卡作为对象，并登记破坏操作信息。
function c47264717.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 首次发动判定：确认场上存在除本卡以外可被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示操作玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由操作玩家从双方场上选择1张除本卡以外的卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息为破坏操作：破坏对象为选择的目标卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：取出效果对象卡，若该卡仍与本次效果关联，则将其破坏。
function c47264717.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时选择的第1个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
