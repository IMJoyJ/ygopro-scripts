--重装機甲 パンツァードラゴン
-- 效果：
-- 机械族怪兽＋龙族怪兽
-- ①：这张卡被破坏送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c72959823.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为机械族怪兽和龙族怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	-- ①：这张卡被破坏送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72959823,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c72959823.descon)
	e1:SetTarget(c72959823.destg)
	e1:SetOperation(c72959823.desop)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否为这张卡被破坏并送去墓地
function c72959823.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果①的靶向处理，确认并选择场上1张卡作为破坏对象
function c72959823.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段检查场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的执行处理，将作为对象的卡破坏
function c72959823.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
