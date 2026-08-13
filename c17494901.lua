--ガガガボルト
-- 效果：
-- 自己场上有名字带有「我我我」的怪兽存在的场合才能发动。选择场上1张卡破坏。
function c17494901.initial_effect(c)
	-- 自己场上有名字带有「我我我」的怪兽存在的场合才能发动。选择场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c17494901.condition)
	e1:SetTarget(c17494901.target)
	e1:SetOperation(c17494901.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：判断怪兽是否为表侧表示且卡名带有「我我我」字段，用于发动条件检索。
function c17494901.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
-- 发动条件的判定函数：检查自己场上是否存在至少1只表侧表示且名字带有「我我我」的怪兽。
function c17494901.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己怪兽区检索是否存在至少1只满足「表侧表示且为我我我字段」的怪兽，作为能否发动的判定依据。
	return Duel.IsExistingMatchingCard(c17494901.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的取对象处理：先确认存在合法对象，再提示玩家选择场上1张卡（不能选择本卡）作为破坏对象，并登记破坏信息。
function c17494901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 在效果发动前检查场上是否存在除本卡以外的、可作为效果对象的卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向当前玩家显示选择提示消息「请选择要破坏的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1张卡作为效果对象，并自动将该卡锁定为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记本连锁将破坏1张卡片的操作信息，供其他卡牌效果（如星尘龙等）进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果结算处理：取得发动时选择的目标，若目标仍与该效果关联，则将其破坏。
function c17494901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时锁定的对象卡（即发动时选择的那张场上卡片）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以「效果」的原因将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
