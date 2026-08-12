--呪眼の女王 ゴルゴーネ
-- 效果：
-- 包含「咒眼」怪兽的怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升自己墓地的「咒眼」卡种类×100。
-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只怪兽破坏。
function c29357687.initial_effect(c)
	-- 连接召唤手续：使用2个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,c29357687.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升自己墓地的「咒眼」卡种类×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c29357687.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29357687,0))  --"对方怪兽效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,29357687)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c29357687.discon)
	e2:SetTarget(c29357687.distg)
	e2:SetOperation(c29357687.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29357687,1))  --"这张卡所连接区1只怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c29357687.descon)
	e3:SetTarget(c29357687.destg)
	e3:SetOperation(c29357687.desop)
	c:RegisterEffect(e3)
end
-- 连接素材必须包含「咒眼」怪兽
function c29357687.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x129)
end
-- 计算墓地「咒眼」卡种类数并乘以100作为攻击力加成
function c29357687.atkval(e,c)
	-- 检索自己墓地所有「咒眼」卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x129)
	return g:GetClassCount(Card.GetCode)*100
end
-- 判断是否装备了「太阴之咒眼」
function c29357687.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,44133040)
end
-- 设置效果目标：选择对方场上一只效果怪兽
function c29357687.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 目标选择条件：对方场上、对方控制、拥有效果的怪兽
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上一只效果怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息：将目标怪兽设为无效化对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 判断当前阶段是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录效果发动的回合数，用于触发下次准备阶段的效果
		e:GetHandler():RegisterFlagEffect(29357687,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(29357687,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- 执行效果：使目标怪兽效果无效
function c29357687.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否满足触发条件：上次发动效果的回合不是当前回合
function c29357687.descon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(29357687)
	-- 判断是否满足触发条件：上次发动效果的回合不是当前回合
	return tid and tid~=Duel.GetTurnCount()
end
-- 破坏效果的过滤函数：判断怪兽是否在连接区
function c29357687.desfilter(c,g)
	return g:IsContains(c)
end
-- 设置破坏效果的目标：选择连接区的一只怪兽
function c29357687.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetLinkedGroup()
	-- 检索连接区的所有怪兽
	local g=Duel.GetMatchingGroup(c29357687.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置效果操作信息：将目标怪兽设为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果：破坏连接区的一只怪兽
function c29357687.desop(e,tp,eg,ep,ev,re,r,rp)
	local cg=e:GetHandler():GetLinkedGroup()
	-- 检索连接区的所有怪兽
	local g=Duel.GetMatchingGroup(c29357687.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示被选为破坏对象的动画
		Duel.HintSelection(sg)
		-- 将目标怪兽破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
