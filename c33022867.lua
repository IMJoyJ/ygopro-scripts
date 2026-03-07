--魔獣皇帝ガーゼット
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽解放的场合才能特殊召唤。
-- ①：这张卡的攻击力变成因为这张卡特殊召唤而解放的怪兽的原本攻击力合计数值。
-- ②：只要这张卡在怪兽区域存在，对方在战斗阶段中不能把魔法·陷阱·怪兽的效果发动。
function c33022867.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c33022867.spcon)
	e2:SetTarget(c33022867.sptg)
	e2:SetOperation(c33022867.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，对方在战斗阶段中不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c33022867.condition)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 检查玩家场上是否有满足条件的3只怪兽可以解放用于特殊召唤。
function c33022867.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的怪兽组（不包括手卡）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 判断该组怪兽中是否存在3只可以同时解放的组合。
	return rg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 选择并确认要解放的3只怪兽。
function c33022867.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组（不包括手卡）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家提示“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放怪兽组中选择3只满足条件的怪兽。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的处理：解放选中的怪兽并计算攻击力。
function c33022867.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽组进行解放操作。
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
	-- 设置自身攻击力为因特殊召唤而解放的怪兽的原本攻击力总和。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
-- 判断当前是否处于战斗阶段。
function c33022867.condition(e)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
