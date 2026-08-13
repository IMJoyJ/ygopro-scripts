--EMラクダウン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。对方场上的全部怪兽的守备力直到回合结束时下降800，这个回合作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽效果】
-- ①：这张卡被战斗破坏的场合才能发动。让把这张卡破坏的怪兽的攻击力下降800。
function c44481227.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤、灵摆区发动效果等），使其作为灵摆怪兽能够在灵摆区发动灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。对方场上的全部怪兽的守备力直到回合结束时下降800，这个回合作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c44481227.condition)
	e2:SetTarget(c44481227.target)
	e2:SetOperation(c44481227.operation)
	c:RegisterEffect(e2)
	-- ①：这张卡被战斗破坏的场合才能发动。让把这张卡破坏的怪兽的攻击力下降800。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c44481227.atkcon)
	e3:SetOperation(c44481227.atkop)
	c:RegisterEffect(e3)
end
-- 灵摆效果的发动条件判定：当前回合玩家必须能够进入战斗阶段，才能发动该效果。
function c44481227.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否仍能进入战斗阶段，若能则发动条件成立。
	return Duel.IsAbleToEnterBP()
end
-- 定义效果可选对象的过滤条件：对象必须是表侧表示怪兽，且尚未获得贯穿伤害效果，避免重复赋予。
function c44481227.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 效果发动时的目标检查与选择流程：若在连锁处理中检查已选择对象chkc，则确认其为己方场上表侧表示且符合过滤条件；若为发动合法性检查chk==0，则确认己方场上存在可选对象且对方场上有表侧表示怪兽。
function c44481227.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44481227.filter(chkc) end
	-- 发动合法性检查：确认自己场上有至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c44481227.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认对方场上有至少1只表侧表示怪兽，否则降低守备力的处理没有意义。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示“请选择效果的对象”的提示消息，用于引导选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示且符合条件的怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c44481227.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽和对方场上全部表侧表示怪兽；令那些对方怪兽守备力下降800；若对象怪兽仍与效果关联，则给它赋予贯穿伤害效果，直到回合结束。
function c44481227.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取对方场上全部表侧表示怪兽的集合，用于统一下降守备力。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local gc=g:GetFirst()
	while gc do
		-- 对方场上的全部怪兽的守备力直到回合结束时下降800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		gc:RegisterEffect(e1)
		gc=g:GetNext()
	end
	if tc:IsRelateToEffect(e) then
		-- 这个回合作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 怪兽效果的发动条件：这张卡被战斗破坏时，取得破坏它的怪兽，并确认其仍与本次战斗关联（没有在战斗中离场等），条件才成立。
function c44481227.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsRelateToBattle()
end
-- 怪兽效果处理：取得导致这张卡被战斗破坏的怪兽，若其仍与战斗关联，则使其攻击力下降800，并设置标准重置条件。
function c44481227.atkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToBattle() then
		-- 让把这张卡破坏的怪兽的攻击力下降800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
