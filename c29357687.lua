--呪眼の女王 ゴルゴーネ
-- 效果：
-- 包含「咒眼」怪兽的怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升自己墓地的「咒眼」卡种类×100。
-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只怪兽破坏。
function c29357687.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只怪兽作为素材，其中必须包含1只「咒眼」怪兽。
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
-- lcheck过滤函数，检测作为连接素材的怪兽组中是否存在至少1只「咒眼」怪兽，满足“包含「咒眼」怪兽的怪兽2只”的素材要求。
function c29357687.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x129)
end
-- 攻击力上升值计算函数：统计自己墓地中不同卡名的「咒眼」卡种类数，再乘以100。
function c29357687.atkval(e,c)
	-- 获取自己墓地中所有「咒眼」系列卡（setname=0x129）的集合。
	local g=Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x129)
	return g:GetClassCount(Card.GetCode)*100
end
-- discon是②的发动条件判断：这张卡装备有「太阴之咒眼」（卡号44133040）时才可发动。
function c29357687.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,44133040)
end
-- distg是②的取对象效果发动时的目标选择与标记函数：选择对方场上1只表侧表示且可被无效的效果怪兽作为对象，并根据当前是否为准备阶段记录flag，供③在下次准备阶段触发。
function c29357687.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若是连锁处理中检查已选对象合法性，则要求该对象在场上、由对方控制，并且是可被无效的表侧效果怪兽。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 发动前检查：对方场上是否存在至少1只符合条件的可无效效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，引导玩家选择要无效的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择1只可无效的效果怪兽，并设为该效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将连锁的操作信息设置为“效果无效化”（CATEGORY_DISABLE），并声明对象为已选中的那只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 判断当前是否为准备阶段，用于决定③标记的持续时长。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 若在准备阶段发动②，给这张卡注册一个誓约标记：记录当前回合数，并设定该标记在下一个准备阶段结束时重置，从而让③在下次准备阶段触发。
		e:GetHandler():RegisterFlagEffect(29357687,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(29357687,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- disop是②的效果处理：若对象怪兽仍表侧表示且与效果关联，则将其怪兽效果无效化（包括卡面效果与已发动/适用的效果），直到回合结束。
function c29357687.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②所选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使对象怪兽本身及其相关的连锁效果无效化，并在对象变里侧表示时重置该无效状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- descon是③的发动条件：检查②发动时留下的flag存在，并且当前回合不是flag记录的发动回合，即已到“下次的准备阶段”。
function c29357687.descon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(29357687)
	-- 返回flag标记存在且记录的回合数不等于当前回合，确认③应在本次准备阶段发动。
	return tid and tid~=Duel.GetTurnCount()
end
-- desfilter是过滤函数，判断某只怪兽是否位于这张卡的连接区域内（即属于其连接区）。
function c29357687.desfilter(c,g)
	return g:IsContains(c)
end
-- destg是③的发动时目标设定：因③为不取对象的破坏效果，发动时获取所有连接区怪兽并设置操作信息，具体选哪只在处理时决定。
function c29357687.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetLinkedGroup()
	-- 获取这张卡连接区域内的所有怪兽。
	local g=Duel.GetMatchingGroup(c29357687.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置操作信息，声明本次连锁将破坏1只连接区怪兽，具体对象在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- desop是③的效果处理：从连接区域内的怪兽中选择1只并破坏。
function c29357687.desop(e,tp,eg,ep,ev,re,r,rp)
	local cg=e:GetHandler():GetLinkedGroup()
	-- 再次获取这张卡连接区域内的所有怪兽，用于效果处理时选择破坏对象。
	local g=Duel.GetMatchingGroup(c29357687.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	if g:GetCount()>0 then
		-- 弹出选择提示，引导玩家选择要破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示选中怪兽的动画，并记录该卡被选为对象（广义上的对象），使相关连锁判定能正确关联。
		Duel.HintSelection(sg)
		-- 将选中的怪兽以效果原因破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
