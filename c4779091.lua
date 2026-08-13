--ユベル－Das Abscheulich Ritter
-- 效果：
-- 这张卡不能通常召唤，用「于贝尔」的效果才能特殊召唤。
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：攻击表示的这张卡被选择作为攻击对象的场合，那次伤害计算前发动。给与对方攻击怪兽的攻击力数值的伤害。
-- ③：自己结束阶段发动。场上的其他怪兽全部破坏。
-- ④：表侧表示的这张卡从场上离开时才能发动。从自己的手卡·卡组·墓地把1只「于贝尔-极度悲伤的魔龙」特殊召唤。
function c4779091.initial_effect(c)
	-- 将效果文本中记载的卡名「于贝尔」（卡号78371393）登记到这张卡上，使相关效果能识别这张卡与「于贝尔」的关联。
	aux.AddCodeList(c,78371393)
	c:EnableReviveLimit()
	-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：攻击表示的这张卡被选择作为攻击对象的场合，那次伤害计算前发动。给与对方攻击怪兽的攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4779091,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c4779091.damcon)
	e3:SetTarget(c4779091.damtg)
	e3:SetOperation(c4779091.damop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段发动。场上的其他怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e4:SetDescription(aux.Stringid(4779091,1))  --"破坏"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(c4779091.descon)
	e4:SetTarget(c4779091.destg)
	e4:SetOperation(c4779091.desop)
	c:RegisterEffect(e4)
	-- ④：表侧表示的这张卡从场上离开时才能发动。从自己的手卡·卡组·墓地把1只「于贝尔-极度悲伤的魔龙」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(4779091,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCondition(c4779091.spcon)
	e5:SetTarget(c4779091.sptg)
	e5:SetOperation(c4779091.spop)
	c:RegisterEffect(e5)
	-- 这张卡不能通常召唤，用「于贝尔」的效果才能特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e6)
end
-- damcon函数：判断效果持有者是否正是当前被选择为攻击对象的怪兽，即确认这张卡被攻击。
function c4779091.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“效果持有者等于当前攻击对象”的判定结果，用于②效果的发动条件。
	return e:GetHandler()==Duel.GetAttackTarget()
end
-- damtg函数：②效果的发动条件与目标设定：确认自身为攻击表示；将伤害对象玩家设为对方；取攻击怪兽的攻击力作为伤害值；并设置伤害效果的操作信息。
function c4779091.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 将本连锁的对象玩家设置为对方玩家（1-tp），表示效果伤害的承受者是对方。
	Duel.SetTargetPlayer(1-tp)
	-- 取得当前攻击怪兽的当前攻击力数值，作为将要给予对方的伤害数值。
	local atk=Duel.GetAttacker():GetAttack()
	-- 将取得的攻击力数值存入当前连锁的对象参数，供效果处理时取出。
	Duel.SetTargetParam(atk)
	-- 设置操作信息：本连锁包含伤害效果，伤害对象为对方玩家，伤害值为攻击力数值，以供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- damop函数：效果实际处理时，从连锁信息中读出对象玩家和伤害值，并对对象玩家造成效果伤害。
function c4779091.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中存储的对象玩家和对象参数，即之前设定的伤害对象和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以卡的效果为原因，对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- descon函数：③效果的发动条件，确认当前回合玩家是这张卡的控制者（自己的回合）。
function c4779091.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于效果控制者，用于确保只在“自己结束阶段”时发动③效果。
	return Duel.GetTurnPlayer()==tp
end
-- destg函数：③效果的发动时目标设定：获取场上除自身以外的所有怪兽作为破坏对象，并设置破坏效果的操作信息。
function c4779091.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方怪兽区域中除自身以外的所有怪兽（无条件过滤，排除自身）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息：本次连锁将破坏上述g中的怪兽，数量为g的卡数，用于后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- desop函数：③效果的实际处理：再次获取场上除自身以外的所有怪兽，并将它们全部破坏。
function c4779091.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除自身以外的所有怪兽（通过aux.ExceptThisCard排除效果持有者自身）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 以效果破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- spcon函数：④效果的发动条件，判断这张卡离场前是否为表侧表示。
function c4779091.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- filter函数：特殊召唤对象过滤条件：卡号为31764700（「于贝尔-极度悲伤的魔龙」），且可以被这次效果特殊召唤（不检查召唤条件与苏生限制）。
function c4779091.filter(c,e,tp)
	return c:IsCode(31764700) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- sptg函数：④效果的发动条件与目标设定：检查自己主要怪兽区有空位，且手卡·卡组·墓地存在符合条件的「于贝尔-极度悲伤的魔龙」，并设置特殊召唤的操作信息。
function c4779091.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己的主要怪兽区是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡·卡组·墓地是否存在至少1张符合条件的「于贝尔-极度悲伤的魔龙」。
		and Duel.IsExistingMatchingCard(c4779091.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息：从自己的手卡·卡组·墓地特殊召唤1只怪兽，因具体对象不确定，targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- spop函数：④效果的实际处理：若主要怪兽区仍有空位，玩家从自己的手卡·卡组·墓地选择1只符合条件的「于贝尔-极度悲伤的魔龙」，以表侧表示特殊召唤并完成特殊召唤手续。
function c4779091.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区是否有空位，没有空位则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，提示其从手卡·卡组·墓地选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·墓地选出1张符合条件的「于贝尔-极度悲伤的魔龙」（过滤时考虑王家长眠之谷的影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4779091.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
