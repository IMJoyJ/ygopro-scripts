--D.D.デストロイヤー
-- 效果：
-- 场上存在的这张卡从游戏中除外时，可以选择对方场上表侧表示存在的1张卡破坏。
function c44792253.initial_effect(c)
	-- 场上存在的这张卡从游戏中除外时，可以选择对方场上表侧表示存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44792253,0))  --"对方场上表侧表示存在的1张卡破坏"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c44792253.descon)
	e1:SetTarget(c44792253.destg)
	e1:SetOperation(c44792253.desop)
	c:RegisterEffect(e1)
end
-- 触发条件：这张卡被除外前位于场上且当时的表示形式为表侧表示，即满足“场上存在的这张卡从游戏中除外”的条件。
function c44792253.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 对象过滤条件：选择的对象必须是表侧表示的卡。
function c44792253.filter(c)
	return c:IsFaceup()
end
-- 取对象效果的目标处理：确认对方场上有表侧表示卡可以成为对象后，选择对方场上的1张表侧表示卡作为对象，并设定破坏该卡的操作信息。
function c44792253.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c44792253.filter(chkc) end
	-- 发动时判定：检查对方场上是否存在1张满足条件的表侧表示卡，若无则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c44792253.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择框提示，提示文字为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张表侧表示卡作为效果对象，并通过SelectTarget将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44792253.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定操作信息：本次效果将破坏所选择的1张卡，类别为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得发动时选择的对象卡，若该卡仍然与效果关联，则将其破坏。
function c44792253.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
