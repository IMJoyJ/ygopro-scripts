--剛鬼サンダー・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：只要这张卡在怪兽区域存在，回合玩家让以下效果适用。
-- ●自己主要阶段在通常召唤外加上只有1次，可以从手卡把1只怪兽往作为这张卡所连接区的自己场上召唤。
-- ②：这张卡所连接区的怪兽被战斗·效果破坏的场合才能发动。这张卡的攻击力上升400。
function c30010480.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求使用2只以上的「刚鬼」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，回合玩家让以下效果适用。●自己主要阶段在通常召唤外加上只有1次，可以从手卡把1只怪兽往作为这张卡所连接区的自己场上召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30010480,0))  --"使用「刚鬼 雷霆食人魔」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetValue(c30010480.sumval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽被战斗·效果破坏的场合才能发动。这张卡的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30010480,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c30010480.atkcon)
	e3:SetOperation(c30010480.atkop)
	c:RegisterEffect(e3)
end
-- 定义e1的Value函数：根据要通常召唤的怪兽控制者（本卡控制者或对方），返回本次附加通常召唤的可召唤区域（本卡的连接区）并排除本卡自身所在格子，从而限定只能把手卡怪兽通常召唤到这张卡的连接区域。
function c30010480.sumval(e,c)
	if c:IsControler(e:GetHandlerPlayer()) then
		local sumzone=e:GetHandler():GetLinkedZone()
		local relzone=-bit.lshift(1,e:GetHandler():GetSequence())
		return 0,sumzone,relzone
	else
		local sumzone=e:GetHandler():GetLinkedZone(1-e:GetHandlerPlayer())
		local relzone=-bit.lshift(1,e:GetHandler():GetSequence()+16)
		return 0,sumzone,relzone
	end
end
-- 筛选被破坏的怪兽是否符合②的发动条件：该怪兽是被战斗或效果破坏、破坏前在怪兽区域、并且其破坏前的格子位于这张卡的连接区域内（对方控制时格子编号+16）。
function c30010480.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- ②的发动条件：本次被破坏的怪兽集合中存在至少1只位于这张卡连接区且因战斗或效果被破坏的怪兽。
function c30010480.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30010480.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- ②的效果处理：这张卡仍表侧表示且与效果相关时，给自己注册一个攻击力上升400的效果，持续到离场或无效等标准重置时机。
function c30010480.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
