--ヴェルズ・ザッハーク
-- 效果：
-- ①：场上的表侧表示的这张卡被对方破坏送去墓地的场合，以场上1只特殊召唤的5星以上的怪兽为对象发动。那只5星以上的怪兽破坏。
function c3536537.initial_effect(c)
	-- ①：场上的表侧表示的这张卡被对方破坏送去墓地的场合，以场上1只特殊召唤的5星以上的怪兽为对象发动。那只5星以上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3536537,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c3536537.descon)
	e1:SetTarget(c3536537.destg)
	e1:SetOperation(c3536537.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡被对手破坏并送去墓地，且破坏前此卡在自己场上表侧表示。
function c3536537.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and bit.band(r,REASON_DESTROY)~=0
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果处理时的对象筛选条件：表侧表示、等级5以上、且为特殊召唤的怪兽。
function c3536537.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动时进行取对象：从双方怪兽区域选择1只满足条件的怪兽（表侧表示、5星以上、特殊召唤）作为效果对象，同时设置破坏的操作信息。
function c3536537.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3536537.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示‘请选择要破坏的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方怪兽区域选择1只符合条件的怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c3536537.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为破坏目标，以便其他卡能够响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取出之前选择的对象，若对象仍然合法则将其破坏。
function c3536537.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得被选择为对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果破坏的方式将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
