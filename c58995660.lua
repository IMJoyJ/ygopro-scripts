--先手必掌
-- 效果：
-- ①：1回合1次，自己怪兽进行战斗的攻击宣言时才能发动。掷1次骰子，出现的数目的以下效果对那只自己怪兽直到回合结束时适用。相同纵列的怪兽之间进行战斗的攻击宣言时发动的场合，不掷骰子从以下效果选1个。
-- ●1·4：只有1次不会被战斗·效果破坏。
-- ●2·5：攻击力下降500，不受「先手必掌」以外的魔法·陷阱卡发动的效果影响。
-- ●3·6：攻击力上升1000，同1次的战斗阶段中最多2次可以向怪兽攻击。
local s,id,o=GetID()
-- 注册卡片发动效果以及在自己怪兽进行战斗的攻击宣言时发动的诱发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己怪兽进行战斗的攻击宣言时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备：获取战斗怪兽并设为效果对象，判断是否在相同纵列，并据此设置是否掷骰子的标记与操作信息。
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行战斗的自己怪兽与对方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	if chk==0 then return a end
	-- 将进行战斗的自己怪兽设为当前连锁的效果处理对象。
	Duel.SetTargetCard(a)
	local g=a:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if d and g:IsContains(d) then
		e:SetLabel(1)
		-- 设置掷1次骰子的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	else
		e:SetLabel(0)
	end
end
-- 效果①的效果处理：根据是否处于相同纵列，让玩家选择效果适用或通过掷骰子随机适用对应的效果。
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的自己怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	local d=0
	if e:GetLabel()==1 then
		-- 相同纵列怪兽战斗时，不掷骰子，由玩家从三个效果中选择一个适用。
		d=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))+1  --"不被破坏/效果免疫/连续攻击"
	else
		-- 非相同纵列怪兽战斗时，进行1次掷骰子。
		d=Duel.TossDice(tp,1)
	end
	if d==1 or d==4 then
		-- ●1·4：只有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))  --"「先手必掌」1·4效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(s.indct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	elseif d==2 or d==5 then
		-- ●2·5：攻击力下降500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 不受「先手必掌」以外的魔法·陷阱卡发动的效果影响。
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,5))  --"「先手必掌」2·5效果适用中"
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCode(EFFECT_IMMUNE_EFFECT)
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e3:SetValue(s.efilter)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	elseif d==3 or d==6 then
		-- ●3·6：攻击力上升1000
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetValue(1000)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 同1次的战斗阶段中最多2次可以向怪兽攻击。
			local e5=Effect.CreateEffect(c)
			e5:SetDescription(aux.Stringid(id,6))  --"「先手必掌」3·6效果适用中"
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
			e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e5:SetValue(1)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e5)
		end
	end
end
-- 判断破坏原因是否为战斗或效果，若是则抵消1次破坏。
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 过滤不受影响的效果，限定为除「先手必掌」以外已发动的魔法·陷阱卡的效果。
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner() and te:IsActivated()
		and not te:GetHandler():IsCode(id)
		and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
