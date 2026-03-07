--ヴェルズ・ザッハーク
-- 效果：
-- ①：场上的表侧表示的这张卡被对方破坏送去墓地的场合，以场上1只特殊召唤的5星以上的怪兽为对象发动。那只5星以上的怪兽破坏。
function c3536537.initial_effect(c)
	-- 效果原文内容：①：场上的表侧表示的这张卡被对方破坏送去墓地的场合，以场上1只特殊召唤的5星以上的怪兽为对象发动。那只5星以上的怪兽破坏。
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
-- 规则层面：判断是否为对方破坏送去墓地，且破坏前控制者为玩家自己，且破坏原因包含REASON_DESTROY，且破坏前位置在场上正面表示
function c3536537.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and bit.band(r,REASON_DESTROY)~=0
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 规则层面：筛选场上正面表示、等级5以上、特殊召唤的怪兽
function c3536537.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 规则层面：选择满足条件的怪兽作为破坏对象，并设置操作信息
function c3536537.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3536537.filter(chkc) end
	if chk==0 then return true end
	-- 规则层面：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面：选择场上满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c3536537.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面：设置连锁操作信息为破坏类别，目标为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面：处理效果，对目标怪兽进行破坏
function c3536537.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面：以效果破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
