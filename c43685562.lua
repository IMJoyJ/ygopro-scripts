--Jo－P.U.N.K.デンジャラス・ガブ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。自己场上有「朋克」怪兽存在的场合，再让自己基本分回复作为对象的怪兽的原本攻击力的数值。
function c43685562.initial_effect(c)
	-- 效果作用
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,43685562+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43685562.target)
	e1:SetOperation(c43685562.activate)
	c:RegisterEffect(e1)
end
-- 以对方场上1只效果怪兽为对象才能发动。
function c43685562.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置目标筛选条件为对方场上的表侧表示怪兽且拥有效果
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在满足条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的一只表侧表示效果怪兽作为目标
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，准备回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 筛选函数：检查自己场上是否存在表侧表示的「朋克」怪兽
function c43685562.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- 效果处理
function c43685562.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果在回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 立即刷新目标怪兽的状态
		Duel.AdjustInstantly(tc)
		-- 检查自己场上是否存在「朋克」怪兽
		if Duel.IsExistingMatchingCard(c43685562.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 回复相当于目标怪兽原本攻击力数值的LP
			Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
		end
	end
end
