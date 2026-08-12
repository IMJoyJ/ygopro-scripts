--スケイルモース
-- 效果：
-- 只要这张卡场上表侧表示存在，双方玩家1回合只能1次把怪兽特殊召唤。
function c68087897.initial_effect(c)
	-- 开启全局特殊召唤次数限制的标记
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	-- 只要这张卡场上表侧表示存在，双方玩家1回合只能1次把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
