--墓守の末裔
-- 效果：
-- 把这张卡以外的自己场上表侧表示存在的1只名字带有「守墓」的怪兽解放才能发动。选择对方场上1张卡破坏。
function c30213599.initial_effect(c)
	-- 把这张卡以外的自己场上表侧表示存在的1只名字带有「守墓」的怪兽解放才能发动。选择对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30213599,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c30213599.cost)
	e1:SetTarget(c30213599.target)
	e1:SetOperation(c30213599.operation)
	c:RegisterEffect(e1)
end
-- 筛选可作为解放代价的怪兽：必须表侧表示且名字带有「守墓」（字段0x2e）。
function c30213599.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2e)
end
-- 发动代价处理：先检查能否解放符合条件的怪兽，再选择1只并解放。
function c30213599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己场上存在至少1只符合条件的「守墓」怪兽（且不是本卡）可供解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c30213599.costfilter,1,e:GetHandler()) end
	-- 选择1只符合条件的表侧表示「守墓」怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c30213599.costfilter,1,1,e:GetHandler())
	-- 将选择的怪兽解放，作为效果发动所需的cost。
	Duel.Release(sg,REASON_COST)
end
-- 效果发动时的对象选择处理：选择对方场上1张卡作为破坏对象，并设置破坏的操作信息。
function c30213599.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在至少1张可以被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁将执行的破坏操作信息，用于后续时点和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象，若对象仍与该效果关联，则将其破坏。
function c30213599.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对方场上的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
