--召喚制限－ディスコードセクター
-- 效果：
-- 只要这张卡在场上存在，双方玩家不能把持有和自身场上的怪兽相同等级的怪兽特殊召唤。此外，双方玩家不能把持有和自身场上的怪兽相同阶级的怪兽特殊召唤。
function c47594939.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方玩家不能把持有和自身场上的怪兽相同等级的怪兽特殊召唤。此外，双方玩家不能把持有和自身场上的怪兽相同阶级的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c47594939.adjustop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，双方玩家不能把持有和自身场上的怪兽相同等级的怪兽特殊召唤。此外，双方玩家不能把持有和自身场上的怪兽相同阶级的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c47594939.splimit)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	e3:SetLabelObject(g)
end
-- 检查目标怪兽是否为指定等级且控制者为指定玩家
function c47594939.lvfilter(c,lv,tp)
	return c:IsLevel(lv) and c:IsControler(tp)
end
-- 检查目标怪兽是否为指定阶级且控制者为指定玩家
function c47594939.rkfilter(c,rk,tp)
	return c:IsRank(rk) and c:IsControler(tp)
end
-- 判断怪兽是否因等级或阶级与场上怪兽相同而无法特殊召唤
function c47594939.splimit(e,c,sump,sumtype,sumpos,targetp)
	local lv=c:GetLevel()
	local rk=c:GetRank()
	if lv>0 then
		return e:GetLabelObject():IsExists(c47594939.lvfilter,1,nil,lv,sump)
	elseif rk>0 then
		return e:GetLabelObject():IsExists(c47594939.rkfilter,1,nil,rk,sump)
	else return false end
end
-- 在每次调整阶段更新场上存在的正面表示怪兽列表
function c47594939.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前处于伤害步骤但尚未计算战斗伤害，或为伤害计算时，则跳过处理
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 检索场上所有正面表示的怪兽组成卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	e:GetLabelObject():Clear()
	e:GetLabelObject():Merge(g)
end
