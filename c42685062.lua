--地獄からの使い
-- 效果：
-- 这张卡不能特殊召唤。这张卡可以把1只怪兽解放作召唤。这个方法召唤的这张卡的等级变成5星，原本的攻击力·守备力变成一半数值。
function c42685062.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只怪兽解放作召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42685062,0))  --"解放１只怪兽召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c42685062.sumcon)
	e2:SetOperation(c42685062.sumop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
end
-- 判断召唤所需的祭品条件是否满足
function c42685062.sumcon(e,c,minc)
	if c==nil then return true end
	-- 需要至少1个祭品且场上存在满足条件的祭品
	return minc<=1 and Duel.CheckTribute(c,1)
end
-- 执行解放祭品并设置等级与攻击力守备力的效果
function c42685062.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择1个祭品
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 解放所选祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	-- 这个方法召唤的这张卡的等级变成5星，原本的攻击力·守备力变成一半数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(5)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(1300)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	e3:SetValue(900)
	c:RegisterEffect(e3)
end
