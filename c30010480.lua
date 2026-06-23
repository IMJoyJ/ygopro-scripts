--剛鬼サンダー・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：只要这张卡在怪兽区域存在，回合玩家让以下效果适用。
-- ●自己主要阶段在通常召唤外加上只有1次，可以从手卡把1只怪兽往作为这张卡所连接区的自己场上召唤。
-- ②：这张卡所连接区的怪兽被战斗·效果破坏的场合才能发动。这张卡的攻击力上升400。
function c30010480.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只属于『刚鬼』系列的怪兽作为连接素材
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
-- 设置效果适用时的召唤区域和限制条件，返回召唤区域和限制区域
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
-- 判断被破坏的怪兽是否来自连接区，用于触发效果条件
function c30010480.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 判断是否有满足条件的怪兽被破坏，用于触发效果条件
function c30010480.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30010480.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 使自身攻击力上升400点
function c30010480.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身攻击力上升400点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
