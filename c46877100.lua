--スケアクロー・アクロア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
-- ②：只要这张卡在怪兽区域存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽的攻击力上升自己场上的守备表示怪兽数量×300。
local s,id,o=GetID()
-- 创建两个效果，分别用于处理特殊召唤和攻击力上升效果
function c46877100.initial_effect(c)
	-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hspcon)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽的攻击力上升自己场上的守备表示怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c46877100.atktg)
	e2:SetValue(c46877100.atkval)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在表侧表示的恐吓爪牙族怪兽
function s.cfilter(c)
	return c:IsSetCard(0x17a) and c:IsFaceup()
end
-- 计算可特殊召唤的目标区域，根据场上存在的恐吓爪牙族怪兽位置确定相邻或相同纵列的区域
function s.getzone(tp)
	local zone=0
	-- 获取场上所有表侧表示的恐吓爪牙族怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历所有符合条件的怪兽
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if seq==5 or seq==6 then
			-- 将额外怪兽区的怪兽所在位置加入目标区域
			zone=zone|(1<<aux.MZoneSequence(seq))
		else
			if seq>0 then zone=zone|(1<<(seq-1)) end
			if seq<4 then zone=zone|(1<<(seq+1)) end
		end
	end
	return zone
end
-- 判断特殊召唤条件是否满足，检查是否有可用区域
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.getzone(tp)
	-- 判断目标区域是否还有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置特殊召唤时的目标区域
function s.hspval(e,c)
	local tp=c:GetControler()
	return 0,s.getzone(tp)
end
-- 设定攻击力上升效果的目标为额外怪兽区的恐吓爪牙族怪兽
function c46877100.atktg(e,c)
	return c:IsSetCard(0x17a) and c:GetSequence()>=5
end
-- 计算场上守备表示怪兽数量并乘以300作为攻击力上升值
function c46877100.atkval(e,c)
	-- 获取场上守备表示怪兽的数量
	return Duel.GetMatchingGroupCount(Card.IsDefensePos,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
