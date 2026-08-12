--世壊賛歌
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽和对方场上1只效果怪兽为对象才能发动。那只自己怪兽破坏，那只对方怪兽的效果直到回合结束时无效。那之后，场上有「维萨斯-斯塔弗罗斯特」存在的场合，可以把作为对象的怪兽破坏。
-- ②：场上有「吠陀」怪兽卡存在的场合，自己主要阶段把墓地的这张卡除外才能发动。自己场上1只怪兽破坏。
function c54851325.initial_effect(c)
	-- 注册卡片记载了「维萨斯-斯塔弗罗斯特」的关系，以便相关卡片检索
	aux.AddCodeList(c,56099748)
	-- ①：以自己场上1只怪兽和对方场上1只效果怪兽为对象才能发动。那只自己怪兽破坏，那只对方怪兽的效果直到回合结束时无效。那之后，场上有「维萨斯-斯塔弗罗斯特」存在的场合，可以把作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54851325,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,54851325)
	e1:SetTarget(c54851325.target)
	e1:SetOperation(c54851325.activate)
	c:RegisterEffect(e1)
	-- ②：场上有「吠陀」怪兽卡存在的场合，自己主要阶段把墓地的这张卡除外才能发动。自己场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54851325,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,54851326)
	e2:SetCondition(c54851325.descon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c54851325.destg)
	e2:SetOperation(c54851325.desop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动准备与对象选择
function c54851325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只表侧表示的效果怪兽
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为对象
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只效果怪兽作为对象
	local g2=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，该效果包含破坏自己场上1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置连锁信息，该效果包含无效对方场上1只怪兽效果的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
-- 过滤场上表侧表示的「维萨斯-斯塔弗罗斯特」的条件函数
function c54851325.filter(c)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- ①号效果的处理逻辑
function c54851325.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取本次效果发动的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	-- 如果作为对象的自己怪兽仍存在于场上且由自己控制，则将其破坏
	if hc:IsRelateToEffect(e) and hc:IsControler(tp) and Duel.Destroy(hc,REASON_EFFECT)>0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		-- 无效与该对方怪兽相关的连锁
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只对方怪兽的效果直到回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的效果直到回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 立即刷新场上卡片的无效状态
		Duel.AdjustInstantly(c)
		-- 检查场上是否存在「维萨斯-斯塔弗罗斯特」
		if Duel.IsExistingMatchingCard(c54851325.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择将作为对象的怪兽破坏
			and Duel.SelectYesNo(tp,aux.Stringid(54851325,2)) then  --"是否把对象怪兽破坏？"
			-- 中断当前效果，使后续的破坏处理与前面的无效处理不视为同时进行
			Duel.BreakEffect()
			-- 破坏作为对象的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 过滤场上表侧表示的「吠陀」怪兽卡的条件函数
function c54851325.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19a) and c:GetOriginalType()&TYPE_MONSTER>0
end
-- ②号效果的发动条件判定
function c54851325.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「吠陀」怪兽卡
	return Duel.IsExistingMatchingCard(c54851325.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ②号效果的发动准备与操作信息设置
function c54851325.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以被破坏的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁信息，该效果包含破坏自己场上1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
-- ②号效果的处理逻辑
function c54851325.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显式指示被选中的怪兽
		Duel.HintSelection(g)
		-- 破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
