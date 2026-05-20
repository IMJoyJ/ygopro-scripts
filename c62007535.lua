--インヴェルズ・ホーン
-- 效果：
-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功的场合，得到以下效果。可以支付1000基本分，选择场上存在的1只怪兽破坏。这个效果1回合只能使用1次。
function c62007535.initial_effect(c)
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功的场合，得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c62007535.regcon)
	e1:SetOperation(c62007535.regop)
	c:RegisterEffect(e1)
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c62007535.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查上级召唤的解放素材中是否存在名字带有「侵入魔鬼」的怪兽，并在对应的效果对象上做标记
function c62007535.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x100a) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查此卡是否上级召唤成功，且解放素材中包含名字带有「侵入魔鬼」的怪兽
function c62007535.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 为此卡注册获得的效果（起动效果，1回合1次，支付1000基本分破坏场上1只怪兽）
function c62007535.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 可以支付1000基本分，选择场上存在的1只怪兽破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62007535,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c62007535.cost)
	e1:SetTarget(c62007535.target)
	e1:SetOperation(c62007535.operation)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 检查并支付1000基本分作为发动的代价
function c62007535.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否未被无效，且玩家是否能支付1000基本分
	if chk==0 then return not e:GetHandler():IsDisabled() and Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果发动的靶向处理，选择场上1只怪兽作为破坏对象
function c62007535.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上存在的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，破坏选择的怪兽
function c62007535.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
