--ダイナミスト・エラプション
-- 效果：
-- ①：自己场上的「雾动机龙」怪兽被战斗·效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
function c74582050.initial_effect(c)
	-- ①：自己场上的「雾动机龙」怪兽被战斗·效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c74582050.condition)
	e1:SetTarget(c74582050.target)
	e1:SetOperation(c74582050.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：原本在自己场上表侧表示存在、属于「雾动机龙」系列、因战斗或效果被破坏的怪兽
function c74582050.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousSetCard(0xd8) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 发动条件：被破坏的卡片中存在满足条件的自己场上的「雾动机龙」怪兽
function c74582050.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74582050.cfilter,1,nil,tp)
end
-- 效果发动时的对象选择：确认对方场上存在可选择的卡，并选择其中1张作为破坏对象
function c74582050.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动检查阶段，确认对方场上是否存在至少1张可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示该连锁将破坏所选择的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取选中的对象，若其仍符合条件则将其破坏
function c74582050.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
