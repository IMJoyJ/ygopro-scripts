--発条機雷ゼンマイン
-- 效果：
-- 3星怪兽×2
-- 场上的这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。这个效果适用的回合的结束阶段时1次，选择场上1张卡破坏。
function c78156759.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续，素材为2只3星怪兽
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 场上的这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c78156759.reptg)
	c:RegisterEffect(e1)
	-- 这个效果适用的回合的结束阶段时1次，选择场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78156759,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c78156759.descon)
	e2:SetTarget(c78156759.destg)
	e2:SetOperation(c78156759.desop)
	c:RegisterEffect(e2)
end
-- 代替破坏效果的过滤与检测：检查自身是否因非代替原因被破坏，且自身有超量素材可用于取除
function c78156759.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否适用代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		e:GetHandler():RegisterFlagEffect(78156759,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
-- 破坏效果的发动条件：检查本回合自身是否成功适用过代替破坏效果（即是否存在对应的Flag标记）
function c78156759.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(78156759)~=0
end
-- 破坏效果的靶向处理：在结束阶段时，选择场上1张卡作为破坏对象，并设置破坏的操作信息
function c78156759.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 在客户端显示提示信息，要求玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息，表明此效果会破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行处理：若对象卡片仍存在于场上，则将其破坏
function c78156759.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
