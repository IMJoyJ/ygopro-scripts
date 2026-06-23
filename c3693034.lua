--借カラクリ旅籠蔵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「机巧」怪兽和对方场上1只效果怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽的效果直到回合结束时无效。
-- ②：自己场上有「机巧」怪兽存在的场合，把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
function c3693034.initial_effect(c)
	-- ①：以自己场上1只「机巧」怪兽和对方场上1只效果怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,3693034+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3693034.target)
	e1:SetOperation(c3693034.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「机巧」怪兽存在的场合，把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3693034,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c3693034.poscon)
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3693034.postg)
	e2:SetOperation(c3693034.posop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示的「机巧」怪兽
function c3693034.posfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x11) and c:IsCanChangePosition()
end
-- 判断是否满足①效果的发动条件
function c3693034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上是否存在满足条件的「机巧」怪兽
	if chk==0 then return Duel.IsExistingTarget(c3693034.posfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在满足条件的效果怪兽
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的「机巧」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c3693034.posfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的对方怪兽作为对象
	local g2=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	-- 设置效果处理信息：使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
-- 处理①效果的发动
function c3693034.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	-- 判断「机巧」怪兽是否仍然在场且为己方控制
	if hc:IsRelateToEffect(e) and hc:IsControler(tp) and Duel.ChangePosition(hc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果在回合结束时解除无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 筛选自己场上表侧表示的「机巧」怪兽
function c3693034.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11)
end
-- 判断自己场上是否存在「机巧」怪兽
function c3693034.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在满足条件的「机巧」怪兽
	return Duel.IsExistingMatchingCard(c3693034.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选场上表侧表示且能改变表示形式的怪兽
function c3693034.posfilter2(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 处理②效果的发动
function c3693034.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3693034.posfilter2(chkc) end
	-- 判断是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(c3693034.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的场上怪兽作为对象
	local g=Duel.SelectTarget(tp,c3693034.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理②效果的发动
function c3693034.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的表示形式
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
