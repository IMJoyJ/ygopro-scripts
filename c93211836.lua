--アーミー・ジェネクス
-- 效果：
-- ①：这张卡把「次世代」怪兽解放作上级召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c93211836.initial_effect(c)
	-- ①：这张卡把「次世代」怪兽解放作上级召唤时，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93211836,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c93211836.condition)
	e1:SetTarget(c93211836.target)
	e1:SetOperation(c93211836.operation)
	c:RegisterEffect(e1)
	-- 这张卡把「次世代」怪兽解放作上级召唤时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c93211836.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查上级召唤的素材中是否包含「次世代」怪兽，并在主效果上标记对应数值
function c93211836.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x2) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 确认这张卡是上级召唤成功，且解放的素材中包含「次世代」怪兽
function c93211836.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 效果①的发动准备，检查并选择对方场上的1张卡作为对象，并设置破坏的操作信息
function c93211836.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动阶段，检查对方场上是否存在可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡片作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表明此效果的处理为破坏选中的1张卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理，若对象卡片仍合法存在于对方场上，则将其破坏
function c93211836.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
