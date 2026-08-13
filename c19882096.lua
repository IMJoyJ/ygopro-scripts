--スケアクロー・ベロネア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
-- ②：只要这张卡在怪兽区域存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 注册两个效果：e1是手卡特殊召唤规则效果，包含一回合一次限制和可召唤区域判定；e2是永续效果，使我方额外怪兽区域的「恐吓爪牙族」怪兽获得贯穿伤害。
function c19882096.initial_effect(c)
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
	-- ②：只要这张卡在怪兽区域存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c19882096.ptg)
	c:RegisterEffect(e2)
end
-- 筛选条件：这张卡是表侧表示且属于「恐吓爪牙族」系列。
function s.cfilter(c)
	return c:IsSetCard(0x17a) and c:IsFaceup()
end
-- 计算从手卡可特殊召唤的怪兽区域掩码：遍历我方场上表侧表示的「恐吓爪牙族」怪兽，将其相邻的主怪兽区以及额外怪兽区对应的相同纵列主怪兽区加入可用区域。
function s.getzone(tp)
	local zone=0
	-- 获取我方场上所有表侧表示且属于「恐吓爪牙族」的怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历所获取的「恐吓爪牙族」怪兽集合中的每张卡。
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if seq==5 or seq==6 then
			-- 当前怪兽位于额外怪兽区域时，将与其相同纵列的主怪兽区域（左额外对应1，右额外对应3）加入可用区域。
			zone=zone|(1<<aux.MZoneSequence(seq))
		else
			if seq>0 then zone=zone|(1<<(seq-1)) end
			if seq<4 then zone=zone|(1<<(seq+1)) end
		end
	end
	return zone
end
-- 特殊召唤规则的发动条件：c为空时直接通过；否则计算可用区域后，检查我方主要怪兽区是否有至少一个可用空格。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.getzone(tp)
	-- 判断计算出的可用区域掩码中是否存在可用的主要怪兽区空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 返回特殊召唤处理所需信息：0表示表侧攻击表示，s.getzone(tp)返回可用的怪兽区域掩码。
function s.hspval(e,c)
	local tp=c:GetControler()
	return 0,s.getzone(tp)
end
-- 贯穿伤害效果的适用对象：该怪兽属于「恐吓爪牙族」且位于额外怪兽区域。
function c19882096.ptg(e,c)
	return c:IsSetCard(0x17a) and c:GetSequence()>=5
end
