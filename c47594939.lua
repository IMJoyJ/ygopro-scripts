--召喚制限－ディスコードセクター
-- 效果：
-- 只要这张卡在场上存在，双方玩家不能把持有和自身场上的怪兽相同等级的怪兽特殊召唤。此外，双方玩家不能把持有和自身场上的怪兽相同阶级的怪兽特殊召唤。
function c47594939.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c47594939.adjustop)
	c:RegisterEffect(e2)
	-- 双方玩家不能把持有和自身场上的怪兽相同等级的怪兽特殊召唤。此外，双方玩家不能把持有和自身场上的怪兽相同阶级的怪兽特殊召唤。
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
-- 判断怪兽c是否具有等级lv且控制者为tp，用于从场上怪兽集合中筛选出与将要特殊召唤的怪兽同等级且属于该玩家控制的怪兽。
function c47594939.lvfilter(c,lv,tp)
	return c:IsLevel(lv) and c:IsControler(tp)
end
-- 判断怪兽c是否具有阶级rk且控制者为tp，用于从场上怪兽集合中筛选出与将要特殊召唤的怪兽同阶级且属于该玩家控制的怪兽。
function c47594939.rkfilter(c,rk,tp)
	return c:IsRank(rk) and c:IsControler(tp)
end
-- 作为『不能特殊召唤』效果的判定函数：若要特殊召唤的怪兽有等级，则检查该玩家场上是否存在同等级表侧怪兽；若有阶级，则检查是否存在同阶级表侧怪兽；存在则禁止特殊召唤。
function c47594939.splimit(e,c,sump,sumtype,sumpos,targetp)
	local lv=c:GetLevel()
	local rk=c:GetRank()
	if lv>0 then
		return e:GetLabelObject():IsExists(c47594939.lvfilter,1,nil,lv,sump)
	elseif rk>0 then
		return e:GetLabelObject():IsExists(c47594939.rkfilter,1,nil,rk,sump)
	else return false end
end
-- 在EVENT_ADJUST时点更新记录：获取双方场上全部表侧怪兽存入LabelObject，使『不能特殊召唤』的判定始终基于当前场上表侧的怪兽；若处于伤害计算阶段则跳过更新。
function c47594939.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段，用于判断是否处于需要跳过集合更新的伤害阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前为伤害步骤且尚未进行伤害计算，或已进入伤害计算时，则跳过场上表侧怪兽集合的更新，避免在伤害计算前后产生错误判定。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 获取双方场上所有表侧表示的怪兽，作为后续更新LabelObject集合的数据源。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	e:GetLabelObject():Clear()
	e:GetLabelObject():Merge(g)
end
