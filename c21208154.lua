--邪神アバター
-- 效果：
-- 这张卡不能特殊召唤。把自己场上3只怪兽解放的场合才能通常召唤。
-- ①：这张卡召唤成功的场合发动。用对方回合计算的2回合内，对方不能把魔法·陷阱卡发动。
-- ②：这张卡的攻击力·守备力变成「邪神 神之化身」以外的场上的攻击力最高的怪兽的攻击力＋100的数值。
function c21208154.initial_effect(c)
	-- ①：这张卡召唤成功的场合发动。用对方回合计算的2回合内，对方不能把魔法·陷阱卡发动。
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
	-- 这张卡不能特殊召唤。把自己场上3只怪兽解放的场合才能通常召唤。
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
	-- ①：这张卡召唤成功的场合发动。用对方回合计算的2回合内，对方不能把魔法·陷阱卡发动。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetOperation(c21208154.regop)
	c:RegisterEffect(e6)
	-- 这张卡不能特殊召唤。把自己场上3只怪兽解放的场合才能通常召唤。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(21208154)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end
-- 判断是否满足通常召唤所需的祭品条件（至少3个）
function c21208154.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足通常召唤所需的祭品条件（至少3个）
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 选择并解放3个祭品怪兽
function c21208154.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3个祭品怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的祭品怪兽解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤场上正面表示的非本卡且未被效果影响的怪兽
function c21208154.filter(c)
	return c:IsFaceup() and not c:IsCode(21208154) and not c:IsHasEffect(21208154)
end
-- 计算攻击力最高的怪兽的攻击力并加100作为当前卡的攻击力
function c21208154.adval(e,c)
	-- 获取场上所有正面表示的非本卡怪兽
	local g=Duel.GetMatchingGroup(c21208154.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then
		return 100
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		return val+100
	end
end
-- 注册一个持续到对方回合结束的魔法·陷阱卡发动限制效果
function c21208154.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个持续到对方回合结束的魔法·陷阱卡发动限制效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c21208154.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断效果是否为魔法·陷阱卡发动
function c21208154.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
