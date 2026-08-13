--地獄からの使い
-- 效果：
-- 这张卡不能特殊召唤。这张卡可以把1只怪兽解放作召唤。这个方法召唤的这张卡的等级变成5星，原本的攻击力·守备力变成一半数值。
function c42685062.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只怪兽解放作召唤。这个方法召唤的这张卡的等级变成5星，原本的攻击力·守备力变成一半数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42685062,0))  --"解放１只怪兽召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c42685062.sumcon)
	e2:SetOperation(c42685062.sumop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
end
-- 作为召唤规则效果的发动条件：若c为空表示该召唤方式本身可用；否则要求本次上级召唤所需解放数不超过1，且存在可解放的1只怪兽。
function c42685062.sumcon(e,c,minc)
	if c==nil then return true end
	-- 判断本次召唤的解放数要求不超过1，且场上存在满足条件的1只解放用怪兽。
	return minc<=1 and Duel.CheckTribute(c,1)
end
-- 执行该召唤规则效果的操作：选择1只怪兽作为祭品，将所选怪兽作为召唤素材解放；随后给这张卡依次注册等级变为5星、原本攻击力变为1300、原本守备力变为900的持续效果（对应原本攻击力·守备力变为一半数值）。
function c42685062.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择用于上级召唤这张卡的1只解放怪兽（祭品）。
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 将选择的怪兽作为上级召唤的素材解放（送入墓地）。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	-- 这个方法召唤的这张卡的等级变成5星。
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
