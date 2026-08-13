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
	-- ②：只要这张卡在怪兽区域存在，对方在战斗阶段中不能把魔法·陷阱·怪兽的效果发动。
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
-- 判定特殊召唤条件是否满足：若c为空则视为条件成立；否则检查当前玩家能否从可解放的怪兽中选出3只，使解放后自己场上仍有可用的怪兽区域。
function c33022867.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家可以用于这次特殊召唤解放的怪兽组（仅场上的怪兽，原因是特殊召唤）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查可解放怪兽组中是否存在正好3只怪兽，使解放它们后当前玩家场上仍有剩余的怪兽区域空位。
	return rg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤手续发动时，让玩家从可解放怪兽中选择3只（解放后仍须有怪兽区空位），并将选中的怪兽组保存到效果标签中待用；选择成功才允许发动手续。
function c33022867.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可以用于特殊召唤解放的怪兽组，作为选择解放对象的候选集合。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向当前玩家显示“请选择要解放的卡”的交互提示，用于选择解放怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家以可取消方式从候选组中选出3只怪兽，要求这3只怪兽解放后自己场上仍有可用怪兽区域，返回选中的怪兽组。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 实际执行特殊召唤的处理：解放此前保存的3只怪兽，然后将这些怪兽原本攻击力（大于0的部分）累加，以此值设置这张卡的当前攻击力，并在其离开场上后重置；最后清理临时分组。
function c33022867.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将之前选中的怪兽组解放，作为这次特殊召唤的代价。
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
	-- ①：这张卡的攻击力变成因为这张卡特殊召唤而解放的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
-- 判断当前是否为战斗阶段（从战斗阶段开始到战斗阶段结束），用于限定②效果只在战斗阶段内适用。
function c33022867.condition(e)
	-- 获取当前游戏阶段，用于后续判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
