--剣聖－ネイキッド・ギア・フリード
-- 效果：
-- 这张卡不能通常召唤。「拘束解除」的效果才能特殊召唤。
-- ①：这张卡有装备卡被装备的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
function c57046845.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「拘束解除」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡有装备卡被装备的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57046845,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_EQUIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c57046845.destg)
	e2:SetOperation(c57046845.desop)
	c:RegisterEffect(e2)
end
-- 定义效果①的发动准备函数，处理取对象检测，并选择对方场上的怪兽作为对象
function c57046845.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明该效果的处理为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果①的效果处理函数，将作为对象的怪兽破坏
function c57046845.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为效果对象的怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
