--邪神アバター
-- 效果：
-- 这张卡不能特殊召唤。把自己场上3只怪兽解放的场合才能通常召唤。
-- ①：这张卡召唤成功的场合发动。用对方回合计算的2回合内，对方不能把魔法·陷阱卡发动。
-- ②：这张卡的攻击力·守备力变成「邪神 神之化身」以外的场上的攻击力最高的怪兽的攻击力＋100的数值。
function c21208154.initial_effect(c)
	-- 把自己场上3只怪兽解放的场合才能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c21208154.ttcon)
	e1:SetOperation(c21208154.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	-- 这张卡不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击力·守备力变成「邪神 神之化身」以外的场上的攻击力最高的怪兽的攻击力＋100的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE,EFFECT_FLAG2_WICKED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c21208154.adval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	c:RegisterEffect(e5)
	-- ①：这张卡召唤成功的场合发动。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetOperation(c21208154.regop)
	c:RegisterEffect(e6)
	-- 「邪神 神之化身」以外的场上的攻击力最高的怪兽
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(21208154)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end
-- 该函数是召唤规则效果的发动条件判定：若c为空（表示规则自身的询问）则允许，否则要求上级召唤的解放数不超过3且场上存在3只可解放的怪兽。
function c21208154.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断本次通常召唤的解放数量上限不超过3，并且场上存在至少3只可用于解放的怪兽（作为上级召唤的祭品）。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 该函数是召唤规则效果的处理操作：让玩家选择3只怪兽作为祭品解放，并将其设置为这张卡的召唤素材，完成上级召唤手续。
function c21208154.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家tp从自己场上选择3只怪兽，作为这张卡上级召唤的解放祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的3只怪兽解放，解放原因记为上级召唤的素材解放（REASON_SUMMON+REASON_MATERIAL）。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：筛选出表侧表示、卡名不是「邪神 神之化身」（卡号21208154）、且不带有神之化身专属标记效果的怪兽。
function c21208154.filter(c)
	return c:IsFaceup() and not c:IsCode(21208154) and not c:IsHasEffect(21208154)
end
-- 该函数计算这张卡当前的攻击力·守备力数值：从场上满足条件的怪兽中取最高攻击力，若没有则为100，否则为最高攻击力+100。
function c21208154.adval(e,c)
	-- 获取双方场上所有满足filter条件的表侧表示怪兽（即「邪神 神之化身」以外的怪兽）。
	local g=Duel.GetMatchingGroup(c21208154.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then
		return 100
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		return val+100
	end
end
-- 该函数是①效果的处理操作：在召唤成功时，为对方玩家附加一个持续到对方回合结束的“不能把魔法·陷阱卡发动”的限制效果，持续2个对方回合。
function c21208154.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 用对方回合计算的2回合内，对方不能把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c21208154.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	-- 把这个“不能发动魔法·陷阱卡”的永续效果注册到召唤成功方（tp），使其对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 判定对方试图发动的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），若是则被禁止。
function c21208154.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
