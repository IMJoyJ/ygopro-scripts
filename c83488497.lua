--スケアクロー・アストラ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
-- ②：只要自己场上有守备表示的「恐吓爪牙族」怪兽存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽在同1次的战斗阶段中可以作出最多有那个种类数量的攻击。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤规则（e1）和增加额外怪兽区域「恐吓爪牙族」怪兽攻击次数的永续效果（e2）
function c83488497.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hspcon)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有守备表示的「恐吓爪牙族」怪兽存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽在同1次的战斗阶段中可以作出最多有那个种类数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c83488497.exatkcon)
	e2:SetTarget(c83488497.exatktg)
	e2:SetValue(c83488497.exatkval)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「恐吓爪牙族」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x17a) and c:IsFaceup()
end
-- 计算并返回自己场上「恐吓爪牙族」怪兽的相邻或相同纵列的主要怪兽区域的掩码（Zone）
function s.getzone(tp)
	local zone=0
	-- 获取自己场上所有表侧表示的「恐吓爪牙族」怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这些「恐吓爪牙族」怪兽
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if seq==5 or seq==6 then
			-- 如果怪兽在额外怪兽区域，则将其相同纵列的主要怪兽区域加入可用区域掩码
			zone=zone|(1<<aux.MZoneSequence(seq))
		else
			if seq>0 then zone=zone|(1<<(seq-1)) end
			if seq<4 then zone=zone|(1<<(seq+1)) end
		end
	end
	return zone
end
-- 特殊召唤规则的条件函数：检查在符合条件的区域中是否有可用的怪兽区域空格
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.getzone(tp)
	-- 检查指定的可用区域掩码中是否存在至少1个空闲的主要怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的数值函数：指定特殊召唤到自己场上，且只能选择符合条件的区域
function s.hspval(e,c)
	local tp=c:GetControler()
	return 0,s.getzone(tp)
end
-- 过滤条件：自己场上表侧守备表示的「恐吓爪牙族」怪兽
function c83488497.deffilter(c)
	return c:IsDefensePos() and c:IsSetCard(0x17a) and c:IsFaceup()
end
-- 额外攻击效果的启用条件：自己场上存在守备表示的「恐吓爪牙族」怪兽
function c83488497.exatkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1张表侧守备表示的「恐吓爪牙族」怪兽
	return Duel.IsExistingMatchingCard(c83488497.deffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 额外攻击效果的影响对象：额外怪兽区域的自己的「恐吓爪牙族」怪兽
function c83488497.exatktg(e,c)
	return c:IsSetCard(0x17a) and c:GetSequence()>=5
end
-- 额外攻击次数的计算函数：返回自己场上守备表示的「恐吓爪牙族」怪兽的卡名种类数量减1（作为追加攻击次数）
function c83488497.exatkval(e)
	local tp=e:GetHandlerPlayer()
	-- 获取自己场上所有表侧守备表示的「恐吓爪牙族」怪兽
	local g=Duel.GetMatchingGroup(c83488497.deffilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)-1
end
