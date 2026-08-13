--墓穴の指名者
-- 效果：
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽除外。直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
function c24224830.initial_effect(c)
	-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽除外。直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24224830.target)
	e1:SetOperation(c24224830.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选对方墓地中可作为对象的怪兽，要求是怪兽卡且能够被除外。
function c24224830.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 发动时点处理：检查是否存在符合条件的对方墓地怪兽作为对象，存在则让玩家选择1只除外的对象，并设置除外相关的操作信息。
function c24224830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c24224830.filter(chkc) end
	-- 发动合法性检查：若不存在符合条件的对方墓地怪兽，则不能发动；否则可以发动。
	if chk==0 then return Duel.IsExistingTarget(c24224830.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向操作玩家发送选择提示消息，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 令玩家从对方墓地选择1只满足filter条件的怪兽作为效果对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c24224830.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本连锁的除外操作信息：类别为除外，对象为所选的怪兽，数量为1，所属位置为对方墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理：取出对象怪兽，若仍与效果关联则将其除外，并给其及同名怪兽附加无效化效果。
function c24224830.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁上记录的第一个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与本效果关联，则将其表侧表示除外；只有除外成功且该卡确实在除外区时，才继续设置无效化效果。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		local c=e:GetHandler()
		-- 直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(c24224830.distg)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将此无效化效果注册到当前玩家场上，持续到下次结束阶段（2个阶段结束）。
		Duel.RegisterEffect(e1,tp)
		-- 直到下个回合的结束时，这个效果除外的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c24224830.discon)
		e2:SetOperation(c24224830.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将此连锁无效效果注册到当前玩家，用于在连锁处理时无效同名怪兽效果的发动。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 无效化效果的判定函数：若场上怪兽的原本卡名与被除外的对象怪兽的原本卡名相同，且是效果怪兽，则其效果无效化。
function c24224830.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
-- 连锁无效效果的触发条件：当有怪兽效果发动，且发动怪兽的原本卡名与被除外的对象怪兽相同时，满足条件。
function c24224830.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 连锁无效效果的操作：将满足条件的连锁上的怪兽效果无效化。
function c24224830.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前正在处理的连锁效果无效化。
	Duel.NegateEffect(ev)
end
