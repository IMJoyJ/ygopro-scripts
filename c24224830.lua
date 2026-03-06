--墓穴の指名者
-- 效果：
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽除外。直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
function c24224830.initial_effect(c)
	-- 效果原文内容：①：以对方墓地1只怪兽为对象才能发动。那只怪兽除外。直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24224830.target)
	e1:SetOperation(c24224830.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：怪兽卡且可以除外
function c24224830.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果作用：选择对方墓地的1只怪兽作为对象
function c24224830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c24224830.filter(chkc) end
	-- 效果作用：确认对方墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c24224830.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择对方墓地的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,c24224830.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 效果作用：设置连锁的操作信息，确定要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果原文内容：①：以对方墓地1只怪兽为对象才能发动。那只怪兽除外。直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
function c24224830.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的处理对象卡
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认对象卡是否有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		local c=e:GetHandler()
		-- 效果原文内容：直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(c24224830.distg)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 效果作用：注册一个使怪兽效果无效的永续效果
		Duel.RegisterEffect(e1,tp)
		-- 效果原文内容：直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c24224830.discon)
		e2:SetOperation(c24224830.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 效果作用：注册一个在连锁处理时使效果无效的连续效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 效果作用：判断目标怪兽是否为被除外怪兽的原卡名怪兽
function c24224830.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
-- 效果作用：判断当前处理的连锁是否为被除外怪兽的原卡名怪兽发动的效果
function c24224830.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 效果作用：使当前处理的连锁效果无效
function c24224830.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使当前处理的连锁效果无效
	Duel.NegateEffect(ev)
end
