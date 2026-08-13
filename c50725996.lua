--ブラック・マジシャンズ・ナイト
-- 效果：
-- 这张卡不能通常召唤。「骑士的称号」的效果才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以场上1张卡为对象发动。那张卡破坏。
function c50725996.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「骑士的称号」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以场上1张卡为对象发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c50725996.destg)
	e2:SetOperation(c50725996.desop)
	c:RegisterEffect(e2)
end
-- 效果发动时的取对象处理：从双方场上选择1张卡作为效果对象，并设置对应破坏操作信息。
function c50725996.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 给玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从双方场上选择1张卡作为对象（取对象效果），并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将本次效果处理信息设为“破坏”，对象为已选择的卡，数量为其数量，用于连锁判定及相关互动。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，取出发动时选择的对象卡，若该卡仍与效果关联，则将其破坏。
function c50725996.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏（送去墓地）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
