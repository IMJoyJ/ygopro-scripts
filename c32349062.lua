--DDドッグ
-- 效果：
-- ←3 【灵摆】 3→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以对方场上1只融合·同调·超量怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，灵摆区域的这张卡破坏。
-- 【怪兽效果】
-- ①：1回合1次，对方对融合·同调·超量怪兽的特殊召唤成功的场合，以那1只怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能攻击，效果无效化。
function c32349062.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：以对方场上1只融合·同调·超量怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，灵摆区域的这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32349062,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,32349062)
	e1:SetTarget(c32349062.distg1)
	e1:SetOperation(c32349062.disop1)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方对融合·同调·超量怪兽的特殊召唤成功的场合，以那1只怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32349062,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32349062.discon2)
	e2:SetTarget(c32349062.distg2)
	e2:SetOperation(c32349062.disop2)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的融合·同调·超量怪兽，用于灵摆效果的目标选择
function c32349062.filter(c)
	-- 判断目标怪兽是否为融合·同调·超量怪兽且满足被无效化的条件
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and aux.NegateMonsterFilter(c)
end
-- 设置灵摆效果的目标选择逻辑，限定对方场上的融合·同调·超量怪兽
function c32349062.distg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32349062.filter(chkc) end
	-- 检查是否有符合条件的融合·同调·超量怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c32349062.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的融合·同调·超量怪兽作为目标
	Duel.SelectTarget(tp,c32349062.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定将破坏自身灵摆卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行灵摆效果的处理逻辑，使目标怪兽效果无效并破坏自身
function c32349062.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 破坏自身灵摆卡
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
-- 筛选符合条件的融合·同调·超量怪兽，用于怪兽效果的目标选择
function c32349062.cfilter(c,tp)
	-- 判断目标怪兽是否为融合·同调·超量怪兽且满足被无效化的条件
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and aux.NegateMonsterFilter(c)
end
-- 判断是否有对方特殊召唤成功的融合·同调·超量怪兽
function c32349062.discon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32349062.cfilter,1,nil,tp)
end
-- 判断目标怪兽是否在特殊召唤成功的怪兽列表中
function c32349062.disfilter(c,g)
	return g:IsContains(c)
end
-- 设置怪兽效果的目标选择逻辑，限定对方场上的融合·同调·超量怪兽
function c32349062.distg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c32349062.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32349062.disfilter(chkc,g) end
	-- 检查是否有符合条件的融合·同调·超量怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c32349062.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	if g:GetCount()==1 then
		-- 设置目标怪兽为特殊召唤成功的怪兽
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择要无效的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择对方场上的融合·同调·超量怪兽作为目标
		Duel.SelectTarget(tp,c32349062.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
end
-- 执行怪兽效果的处理逻辑，使目标怪兽不能攻击且效果无效
function c32349062.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsDisabled() then
			-- 使目标怪兽相关的连锁效果无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 使目标怪兽的效果无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
