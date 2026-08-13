--乾燥機塊ドライドレイク
-- 效果：
-- 「机块」怪兽1只
-- 这张卡在连接召唤的回合不能作为连接素材。
-- ①：连接状态的这张卡的攻击力上升1000。
-- ②：自己战斗阶段1次，这张卡是互相连接状态的场合才能发动。选包含这张卡的自己的主要怪兽区域2只「机块」怪兽，那些位置交换。这个回合，那另1只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，不在互相连接状态的这张卡成为攻击对象时才能发动。那次攻击无效。
function c3507053.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以1只「机块」怪兽作为连接素材，使这张卡可以通过连接召唤出场。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c3507053.lmlimit)
	c:RegisterEffect(e1)
	-- ①：连接状态的这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1000)
	e2:SetCondition(c3507053.atkcon)
	c:RegisterEffect(e2)
	-- ②：自己战斗阶段1次，这张卡是互相连接状态的场合才能发动。选包含这张卡的自己的主要怪兽区域2只「机块」怪兽，那些位置交换。这个回合，那另1只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3507053,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_BATTLE_START)
	e3:SetCountLimit(1)
	e3:SetCondition(c3507053.chcon)
	e3:SetTarget(c3507053.chtg)
	e3:SetOperation(c3507053.chop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，不在互相连接状态的这张卡成为攻击对象时才能发动。那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3507053,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c3507053.negcon)
	e4:SetOperation(c3507053.negop)
	c:RegisterEffect(e4)
end
-- 返回此卡是否满足不能作为连接素材的条件：若此卡在本回合通过连接召唤出场，则返回true，即不能作为连接素材。
function c3507053.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 返回此卡是否为连接状态（即与相邻怪兽互相连接），用于决定攻击力上升效果是否适用。
function c3507053.atkcon(e)
	return e:GetHandler():IsLinkState()
end
-- ②效果的发动条件：当前处于自己战斗阶段（开始到结束）、此卡为互相连接状态、且当前没有其他连锁处理，满足时才能发动。
function c3507053.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段并存入本地变量ph，用于后续阶段判断。
	local ph=Duel.GetCurrentPhase()
	-- 判断②效果需要的全部条件：当前阶段在战斗阶段开始到结束之间、此卡处于互相连接状态、当前回合玩家是自己、且连锁为空；只有全部满足才能发动。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and e:GetHandler():GetMutualLinkedGroupCount()>0 and Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()==0
end
-- 过滤函数：选择我方主要怪兽区域（序号小于5，即不包括额外怪兽区）的表侧表示「机块」怪兽，作为②效果可选的目标。
function c3507053.chfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14b) and c:GetSequence()<5
end
-- 分组选择辅助函数：判断选中组g是否包含指定卡c，用于确保选择的两只怪兽中包含这张卡自身。
function c3507053.fselect(g,c)
	return g:IsContains(c)
end
-- ②效果的发动目标检测：检查场上是否存在满足条件且包含此卡的2只「机块」怪兽，若存在则允许发动；实际选择在处理时进行。
function c3507053.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前我方主要怪兽区域中所有符合chfilter条件的表侧表示「机块」怪兽，组成候选集合g。
	local g=Duel.GetMatchingGroup(c3507053.chfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(c3507053.fselect,2,2,e:GetHandler()) end
end
-- ②效果处理：选择包含此卡的2只「机块」怪兽，交换它们的位置，并给其中的另一只怪兽赋予本回合战斗阶段可追加攻击1次的效果。
function c3507053.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 处理时重新获取当前我方主要怪兽区域中符合chfilter条件的「机块」怪兽集合，用于玩家选择。
	local g=Duel.GetMatchingGroup(c3507053.chfilter,tp,LOCATION_MZONE,0,nil)
	-- 显示选择提示，告知玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,c3507053.fselect,false,2,2,c)
	if sg and sg:GetCount()==2 then
		-- 为选中的卡组显示被选为对象的动画，并记录它们被选择，用于连锁处理的对象确认。
		Duel.HintSelection(sg)
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 交换两只怪兽在主要怪兽区域的位置，实现『那些位置交换』。
		Duel.SwapSequence(tc1,tc2)
		local tc=tc1
		if tc==c then tc=tc2 end
		-- 这个回合，那另1只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：此卡不在互相连接状态（互相连接组数量为0）且成为攻击对象时，才能发动。
function c3507053.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()==0
end
-- ③效果处理：无效那次攻击，使其攻击无效。
function c3507053.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateAttack()，将当前攻击无效化。
	Duel.NegateAttack()
end
