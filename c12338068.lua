--真魔獣 ガーゼット
-- 效果：
-- 这张卡不能通常召唤。把自己场上的怪兽全部解放的场合才能特殊召唤。
-- ①：这张卡的攻击力变成因为这张卡特殊召唤而解放的怪兽的原本攻击力合计数值。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c12338068.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上的怪兽全部解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上的怪兽全部解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c12338068.spcon)
	e2:SetOperation(c12338068.spop)
	c:RegisterEffect(e2)
	-- 这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 检查特殊召唤条件
function c12338068.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方场上的怪兽组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取己方可解放的卡片组（不包括手卡）
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return (g:GetCount()>0 or rg:GetCount()>0) and g:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==g:GetCount()
end
-- 执行特殊召唤时的操作
function c12338068.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取己方可解放的卡片组
	local g=Duel.GetReleaseGroup(tp)
	-- 将目标卡片组解放
	Duel.Release(g,REASON_SPSUMMON)
	local atk=0
	local tc=g:GetFirst()
	while tc do
		local batk=tc:GetTextAttack()
		if batk>0 then
			atk=atk+batk
		end
		tc=g:GetNext()
	end
	-- 这张卡的攻击力变成因为这张卡特殊召唤而解放的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
