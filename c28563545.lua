--竜殺者
-- 效果：
-- 这张卡在场上召唤·反转召唤时，破坏表侧表示的1只龙族怪兽。
function c28563545.initial_effect(c)
	-- 这张卡在场上召唤·反转召唤时，破坏表侧表示的1只龙族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28563545,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28563545.target)
	e1:SetOperation(c28563545.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选条件是表侧表示且为龙族怪兽，用于确定可被此效果破坏的对象。
function c28563545.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果发动时的目标处理：若检查已选对象则验证其位于怪兽区且满足筛选条件；若是发动时点则提示选择并选定场上1只表侧龙族怪兽作为效果对象，同时登记破坏信息。
function c28563545.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28563545.filter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区选择1只表侧表示的龙族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c28563545.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的效果处理信息登记为破坏所选对象，类别为破坏效果，数量为选择张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：取得效果对象，若对象仍与效果相关且仍为表侧龙族怪兽，则将其破坏。
function c28563545.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c28563545.filter(tc) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
