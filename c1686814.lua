--アルティマヤ・ツィオルキン
-- 效果：
-- 规则上，这张卡的等级当作12星使用。这张卡不能同调召唤，把自己场上的表侧表示的5星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
-- ①：1回合1次，自己场上有魔法·陷阱卡被盖放时才能发动。把1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽从额外卡组特殊召唤。
-- ②：场上的这张卡只要其他的自己的同调怪兽存在，不会成为攻击对象以及效果的对象。
function c1686814.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤。
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
	-- ①：1回合1次，自己场上有魔法·陷阱卡被盖放时才能发动。把1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽从额外卡组特殊召唤。
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
	-- ②：场上的这张卡只要其他的自己的同调怪兽存在，不会成为攻击对象以及效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c1686814.tgcon)
	-- 设置该效果的判定值：当对方怪兽不免疫此效果时，不能以这张卡为攻击对象。
	e4:SetValue(aux.imval1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 筛选可作为特殊召唤素材的怪兽：必须是表侧表示、等级5以上且可作为代价送去墓地。
function c1686814.sprfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- 检查素材组g是否由1只调整和1只非调整组成，且额外怪兽区域有空格；若不满足则素材选择无效。
function c1686814.fselect(g,tp,sc)
	-- 使用aux.gffcheck检查两张素材中一张为调整、另一张为非调整的组合（顺序不限）。
	if not aux.gffcheck(g,Card.IsType,TYPE_TUNER,aux.NOT(Card.IsType),TYPE_TUNER)
		-- 或者额外怪兽区没有足够空格容纳从额外卡组特殊召唤的这张卡，则返回false。
		or Duel.GetLocationCountFromEx(tp,tp,g,sc)<=0 then return false end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return tc1:IsLevel(tc2:GetLevel())
end
-- 特殊召唤规则的条件：从控制者场上存在的表侧5星以上怪兽中，能够选出2张满足调整+非调整且等级相同组合的素材，并有额外怪兽区空格。
function c1686814.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取控制者场上所有可作为素材的怪兽：表侧表示、5星以上、可作为代价送去墓地。
	local g=Duel.GetMatchingGroup(c1686814.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c1686814.fselect,2,2,tp,c)
end
-- 特殊召唤规则的选择部分：玩家从候选素材中选择2张满足条件的怪兽，保存到效果标签中，供处理时作为代价送去墓地；选择有效则返回true。
function c1686814.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取控制者场上所有可作为素材的怪兽：表侧表示、5星以上、可作为代价送去墓地。
	local g=Duel.GetMatchingGroup(c1686814.sprfilter,tp,LOCATION_MZONE,0,nil)
	-- 发出选择提示，要求玩家选择要送去墓地的怪兽卡（作为特殊召唤素材）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c1686814.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的处理：将之前选定的2张素材怪兽送去墓地，完成召唤代价，并清除保存的标签。
function c1686814.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材怪兽作为特殊召唤的代价送去墓地（REASON_SPSUMMON表示因特殊召唤手续而送去墓地）。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 发动条件：本次被盖放的魔法·陷阱卡中存在这张卡的控制者（自己）盖放的卡。
function c1686814.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 筛选可特殊召唤的额外怪兽：必须是'动力工具'同调怪兽，或7·8星的龙族同调怪兽；并且可被当前效果特殊召唤，额外怪兽区有空位。
function c1686814.spfilter(c,e,tp)
	return (c:IsSetCard(0xc2) or (c:IsLevel(7,8) and c:IsRace(RACE_DRAGON)))
		-- 并且该卡必须是同调怪兽、能够被特殊召唤，且自己的额外怪兽区存在空格。
		and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①的发动时点：检查额外卡组是否有符合条件的怪兽，并登记特殊召唤操作信息。
function c1686814.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定：chk==0时，若额外卡组存在1只以上符合条件的怪兽则满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c1686814.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将把1只额外卡组怪兽特殊召唤，以便其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：玩家从额外卡组选择1只符合条件的同调怪兽，以表侧表示特殊召唤。
function c1686814.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择提示，要求玩家选择要特殊召唤的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的同调怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c1686814.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选条件：表侧表示的同调怪兽，用于判断是否存在'其他的自己的同调怪兽'。
function c1686814.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ②效果的持续条件：这张卡的控制者场上存在其他表侧表示的同调怪兽（不包含自身）。
function c1686814.tgcon(e)
	-- 检测自己场上是否存在至少1只除自身以外的表侧表示同调怪兽，存在则②效果适用。
	return Duel.IsExistingMatchingCard(c1686814.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
