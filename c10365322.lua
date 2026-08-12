--起爆獣ヴァルカノン
-- 效果：
-- 机械族怪兽＋炎族怪兽
-- 这张卡融合召唤成功时，选择对方场上存在的1只怪兽才能发动。选择的对方怪兽和这张卡破坏送去墓地。那之后，给与对方基本分送去墓地的对方怪兽的攻击力数值的伤害。
function c10365322.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤的手续，以机械族怪兽和炎族怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),true)
	-- 这张卡融合召唤成功时，选择对方场上存在的1只怪兽才能发动。选择的对方怪兽和这张卡破坏送去墓地。那之后，给与对方基本分送去墓地的对方怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10365322,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c10365322.descon)
	e2:SetTarget(c10365322.destg)
	e2:SetOperation(c10365322.desop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否为融合召唤成功
function c10365322.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 以对方场上1只怪兽为对象，将该怪兽与此卡作为破坏对象发动，并设置破坏与伤害的操作信息
function c10365322.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 在系统提示栏显示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以对方场上1只怪兽为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置破坏两张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置给与对方伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 破坏作为对象的对方怪兽和此卡送去墓地，并给与对方被破坏送去墓地的对方怪兽攻击力数值的伤害
function c10365322.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	if not tc:IsControler(1-tp) then return end
	local dg=Group.FromCards(c,tc)
	-- 破坏此卡与选中的对方怪兽，并判断是否成功破坏双方并送去墓地
	if Duel.Destroy(dg,REASON_EFFECT)==2 and tc:IsLocation(LOCATION_GRAVE) and c:IsLocation(LOCATION_GRAVE) then
		local d=tc:GetTextAttack()
		if d>0 then
			-- 中断当前效果，使之后的伤害处理视为不同时处理
			Duel.BreakEffect()
			-- 给与对方送去墓地的对方怪兽攻击力数值的伤害
			Duel.Damage(1-tp,d,REASON_EFFECT)
		end
	end
end
