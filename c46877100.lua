--スケアクロー・アクロア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以从手卡往自己场上的「恐吓爪牙族」怪兽的相邻的或者相同纵列的自己的主要怪兽区域特殊召唤。
-- ②：只要这张卡在怪兽区域存在，额外怪兽区域的自己的「恐吓爪牙族」怪兽的攻击力上升自己场上的守备表示怪兽数量×300。
local s,id,o=GetID()
-- 初始化效果：注册两个效果——①手牌中作为规则特殊召唤的效果（带1回合1次誓约限制），②此卡在怪兽区域时为我方额外怪兽区域的「恐吓爪牙族」怪兽提供攻击力加成。
function c46877100.initial_effect(c)
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
-- 过滤条件：己方场上的表侧表示「恐吓爪牙族」怪兽（用于确定可特殊召唤的基准怪兽）。
function s.cfilter(c)
	return c:IsSetCard(0x17a) and c:IsFaceup()
end
-- 计算可特殊召唤的主怪兽区区域位掩码：对己方场上每只表侧「恐吓爪牙族」怪兽，若其在额外怪兽区则将其相同纵列的主怪兽区加入；若在主怪兽区则将其左右相邻的主怪兽区加入；最终返回这些可用格子的位掩码。
function s.getzone(tp)
	local zone=0
	-- 获取己方场上所有符合条件的表侧「恐吓爪牙族」怪兽的集合。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历该集合中的每只怪兽，根据其所在位置逐个计算相邻或相同纵列的可召唤区域。
	for tc in aux.Next(g) do
		local seq=tc:GetSequence()
		if seq==5 or seq==6 then
			-- 若该恐吓爪牙族怪兽位于额外怪兽区（seq为5或6），则通过aux.MZoneSequence将其映射到对应纵列的主怪兽区格子，并将该格子的位掩码合并到可用区域中。
			zone=zone|(1<<aux.MZoneSequence(seq))
		else
			if seq>0 then zone=zone|(1<<(seq-1)) end
			if seq<4 then zone=zone|(1<<(seq+1)) end
		end
	end
	return zone
end
-- 特殊召唤规则的条件：当c为空时视为可行；否则先计算可用的主怪兽区格子位掩码，再通过Duel.GetLocationCount检查这些格子中是否有空位。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.getzone(tp)
	-- 判定可用主怪兽区空格数量大于0，即存在满足‘相邻或相同纵列’条件的位置可进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置该规则特殊召唤的Value值：返回0（表示按默认形式特殊召唤）以及计算出的可用主怪兽区格子位掩码，用于指定召唤区域。
function s.hspval(e,c)
	local tp=c:GetControler()
	return 0,s.getzone(tp)
end
-- 攻击力加成效果的适用对象：己方场上位于额外怪兽区（序号≥5）的「恐吓爪牙族」怪兽。
function c46877100.atktg(e,c)
	return c:IsSetCard(0x17a) and c:GetSequence()>=5
end
-- 攻击力加成数值：以该怪兽的控制者场上的守备表示怪兽数量乘以300作为上升值。
function c46877100.atkval(e,c)
	-- 统计己方场上守备表示怪兽的数量并乘以300，得到具体的攻击力上升数值。
	return Duel.GetMatchingGroupCount(Card.IsDefensePos,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
