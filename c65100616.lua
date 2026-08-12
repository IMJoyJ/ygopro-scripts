--リンク・インフライヤー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以从手卡往作为场上的连接怪兽所连接区的自己场上特殊召唤。
function c65100616.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为场上的连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,65100616+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c65100616.spcon)
	e1:SetValue(c65100616.spval)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则的条件检查函数，判断场上是否存在可用于特殊召唤的连接区
function c65100616.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家视角下所有连接怪兽所指向的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 检查在连接怪兽指向的区域中，自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的数值函数，用于指定特殊召唤时允许放置的区域
function c65100616.spval(e,c)
	-- 返回特殊召唤的目标区域，限制为当前玩家视角下的所有连接区域
	return 0,Duel.GetLinkedZone(c:GetControler())
end
