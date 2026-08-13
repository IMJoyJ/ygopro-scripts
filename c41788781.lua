--極星獣グルファクシ
-- 效果：
-- 对方场上有同调怪兽表侧表示存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c41788781.initial_effect(c)
	-- 对方场上有同调怪兽表侧表示存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c41788781.spcon)
	c:RegisterEffect(e1)
end
-- 定义过滤器函数：判断一张卡是否为表侧表示且为同调怪兽，用于后续筛选对方场上的同调怪兽。
function c41788781.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 定义该特殊召唤效果的条件函数：当c为空时视为允许进行规则特殊召唤；否则需满足自己主要怪兽区有空位、自己场上无怪兽且对方场上有表侧同调怪兽。
function c41788781.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的持有者/控制者（自己）的主要怪兽区域是否有空格，确保有位置可以特殊召唤这张卡。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上主要怪兽区域没有怪兽存在，满足“自己场上没有怪兽存在”的特殊召唤条件。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在至少1只表侧表示的同调怪兽，满足“对方场上有同调怪兽表侧表示存在”的特殊召唤条件。
		and	Duel.IsExistingMatchingCard(c41788781.filter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
