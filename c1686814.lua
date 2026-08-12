--アルティマヤ・ツィオルキン
-- 效果：
-- 规则上，这张卡的等级当作12星使用。这张卡不能同调召唤，把自己场上的表侧表示的5星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
-- ①：1回合1次，自己场上有魔法·陷阱卡被盖放时才能发动。把1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽从额外卡组特殊召唤。
-- ②：场上的这张卡只要其他的自己的同调怪兽存在，不会成为攻击对象以及效果的对象。
function c1686814.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤，把自己场上的表侧表示的5星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上的表侧表示的5星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c1686814.sprcon)
	e2:SetTarget(c1686814.sprtg)
	e2:SetOperation(c1686814.sprop)
	c:RegisterEffect(e2)
	-- 自己场上有魔法·陷阱卡被盖放时才能发动。把1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c1686814.spcon)
	e3:SetTarget(c1686814.sptg)
	e3:SetOperation(c1686814.spop)
	c:RegisterEffect(e3)
	-- 场上的这张卡只要其他的自己的同调怪兽存在，不会成为攻击对象以及效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c1686814.tgcon)
	-- 设置效果值为辅助函数imval1，用于判断是否不会成为攻击对象。
	e4:SetValue(aux.imval1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 筛选场上表侧表示且等级大于等于5的怪兽，且可以作为送去墓地的费用。
function c1686814.sprfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- 检查所选的两个怪兽中一个为调整类型，另一个不是调整类型，并且满足额外召唤区域的空位要求。
function c1686814.fselect(g,tp,sc)
	-- 检查所选的两个怪兽中一个为调整类型，另一个不是调整类型。
	if not aux.gffcheck(g,Card.IsType,TYPE_TUNER,aux.NOT(Card.IsType),TYPE_TUNER)
		-- 检查额外召唤区域是否有足够的空位。
		or Duel.GetLocationCountFromEx(tp,tp,g,sc)<=0 then return false end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return tc1:IsLevel(tc2:GetLevel())
end
-- 判断是否满足特殊召唤的条件，即场上有满足条件的两个怪兽。
function c1686814.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足特殊召唤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c1686814.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c1686814.fselect,2,2,tp,c)
end
-- 选择满足条件的两个怪兽组成组合作为特殊召唤的代价。
function c1686814.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有满足特殊召唤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c1686814.sprfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c1686814.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选中的怪兽组送去墓地。
function c1686814.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽组送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否满足发动条件，即对方场上有魔法·陷阱卡被盖放。
function c1686814.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 筛选满足条件的同调怪兽，包括「动力工具」系列或7·8星龙族同调怪兽。
function c1686814.spfilter(c,e,tp)
	return (c:IsSetCard(0xc2) or (c:IsLevel(7,8) and c:IsRace(RACE_DRAGON)))
		-- 确保该怪兽为同调怪兽且可以特殊召唤，并且额外召唤区域有空位。
		and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置发动效果时的操作信息，准备特殊召唤怪兽。
function c1686814.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即额外卡组中存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1686814.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置发动效果时的操作信息，准备特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 选择并特殊召唤满足条件的怪兽。
function c1686814.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c1686814.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选场上表侧表示的同调怪兽。
function c1686814.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 判断是否满足发动条件，即场上有其他自己的同调怪兽。
function c1686814.tgcon(e)
	-- 判断场上是否存在满足条件的同调怪兽。
	return Duel.IsExistingMatchingCard(c1686814.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
