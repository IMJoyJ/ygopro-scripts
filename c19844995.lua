--召喚制限－パワーフィルター
-- 效果：
-- 双方玩家不能把攻击力1000以下的怪兽特殊召唤。
function c19844995.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 双方玩家不能把攻击力1000以下的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c19844995.sumlimit)
	c:RegisterEffect(e2)
end
-- 检查目标怪兽是否攻击力为1000以下
function c19844995.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsAttackBelow(1000)
end
