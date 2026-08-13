--機炎星－ゴヨウテ
-- 效果：
-- 自己场上有名字带有「炎舞」的魔法·陷阱卡存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c49785720.initial_effect(c)
	-- 自己场上有名字带有「炎舞」的魔法·陷阱卡存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49785720.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否为表侧表示、卡名含有字段「炎舞」（0x7c）且属于魔法·陷阱卡，用于检索满足条件的炎舞魔陷。
function c49785720.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤规则的条件函数：若c为nil则返回true（规则询问）；否则判断自己主怪兽区有空位、自己场上没有怪兽、且自己魔陷区存在表侧表示的炎舞魔陷，满足才允许从手卡特殊召唤。
function c49785720.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方的主要怪兽区（LOCATION_MZONE）是否存在可用的空位，大于0表示有空位可供特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上（主要怪兽区）的怪兽数量是否为0，即自己场上没有怪兽存在的场合。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查己方魔陷区是否存在至少1张满足filter条件的卡，即场上是否有表侧表示的、名字带「炎舞」的魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c49785720.filter,tp,LOCATION_SZONE,0,1,nil)
end
