--邪神ドレッド・ルート
-- 效果：
-- 这张卡不能特殊召唤。把自己场上3只怪兽解放的场合才能通常召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽的攻击力·守备力变成一半。
function c62180201.initial_effect(c)
	-- 把自己场上3只怪兽解放的场合才能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c62180201.ttcon)
	e1:SetOperation(c62180201.ttop)
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
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽的攻击力·守备力变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(0,EFFECT_FLAG2_WICKED)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c62180201.atktg)
	e4:SetValue(c62180201.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e5:SetValue(c62180201.defval)
	c:RegisterEffect(e5)
end
-- 通常召唤（上级召唤）的手续条件判定
function c62180201.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否满足解放3只怪兽进行通常召唤的条件
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 执行通常召唤（上级召唤）时的解放操作
function c62180201.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择场上3只怪兽作为解放的祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的怪兽作为召唤素材解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 确定效果适用对象为这张卡以外的场上怪兽
function c62180201.atktg(e,c)
	return c~=e:GetHandler()
end
-- 计算并返回目标怪兽攻击力的一半（向上取整）
function c62180201.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
-- 计算并返回目标怪兽守备力的一半（向上取整）
function c62180201.defval(e,c)
	return math.ceil(c:GetDefense()/2)
end
