--乾燥機塊ドライドレイク
-- 效果：
-- 「机块」怪兽1只
-- 这张卡在连接召唤的回合不能作为连接素材。
-- ①：连接状态的这张卡的攻击力上升1000。
-- ②：自己战斗阶段1次，这张卡是互相连接状态的场合才能发动。选包含这张卡的自己的主要怪兽区域2只「机块」怪兽，那些位置交换。这个回合，那另1只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，不在互相连接状态的这张卡成为攻击对象时才能发动。那次攻击无效。
function c3507053.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，使用机块卡组的怪兽作为连接素材，最少需要1个，最多1个
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c3507053.lmlimit)
	c:RegisterEffect(e1)
	-- 连接状态的这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1000)
	e2:SetCondition(c3507053.atkcon)
	c:RegisterEffect(e2)
	-- 自己战斗阶段1次，这张卡是互相连接状态的场合才能发动。选包含这张卡的自己的主要怪兽区域2只「机块」怪兽，那些位置交换。这个回合，那另1只怪兽在同1次的战斗阶段中可以作2次攻击。
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
	-- 1回合1次，不在互相连接状态的这张卡成为攻击对象时才能发动。那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3507053,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c3507053.negcon)
	e4:SetOperation(c3507053.negop)
	c:RegisterEffect(e4)
end
-- 判断该卡是否在连接召唤的回合被特殊召唤
function c3507053.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 判断该卡是否处于连接状态
function c3507053.atkcon(e)
	return e:GetHandler():IsLinkState()
end
-- 判断当前是否为战斗阶段开始到战斗阶段结束之间，且该卡处于互相连接状态，且为当前回合玩家，且当前没有连锁在处理
function c3507053.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回是否满足战斗阶段条件、互相连接状态、回合玩家和无连锁处理条件
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and e:GetHandler():GetMutualLinkedGroupCount()>0 and Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()==0
end
-- 筛选满足条件的怪兽：表侧表示、机块卡组、位置在主要怪兽区域0-4
function c3507053.chfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14b) and c:GetSequence()<5
end
-- 用于筛选满足条件的怪兽组，确保所选怪兽包含指定的卡
function c3507053.fselect(g,c)
	return g:IsContains(c)
end
-- 设置效果目标，检查是否存在满足条件的2只怪兽组合
function c3507053.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c3507053.chfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(c3507053.fselect,2,2,e:GetHandler()) end
end
-- 处理效果操作，交换2只怪兽位置并为其中一只怪兽增加1次攻击次数
function c3507053.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c3507053.chfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,c3507053.fselect,false,2,2,c)
	if sg and sg:GetCount()==2 then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(sg)
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 交换两只怪兽的位置
		Duel.SwapSequence(tc1,tc2)
		local tc=tc1
		if tc==c then tc=tc2 end
		-- 为指定怪兽增加1次攻击次数
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断该卡是否处于互相连接状态
function c3507053.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()==0
end
-- 无效此次攻击
function c3507053.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	Duel.NegateAttack()
end
