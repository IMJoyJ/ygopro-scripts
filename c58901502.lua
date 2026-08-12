--ゴヨウ・ディフェンダー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，自己场上的怪兽只有战士族·地属性的同调怪兽的场合才能发动。从额外卡组把1只「御用防御者」特殊召唤。
-- ②：这张卡被选择作为攻击对象时才能发动。这张卡的攻击力直到那次伤害步骤结束时上升这张卡以外的自己场上的战士族·地属性的同调怪兽数量×1000。
function c58901502.initial_effect(c)
	-- 设置同调召唤的手续：需要1只调整怪兽，以及1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己场上的怪兽只有战士族·地属性的同调怪兽的场合才能发动。从额外卡组把1只「御用防御者」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58901502,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c58901502.spcon)
	e1:SetTarget(c58901502.sptg)
	e1:SetOperation(c58901502.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被选择作为攻击对象时才能发动。这张卡的攻击力直到那次伤害步骤结束时上升这张卡以外的自己场上的战士族·地属性的同调怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58901502,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetOperation(c58901502.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：里侧表示怪兽，或者不是战士族·地属性的同调怪兽（用于检测是否存在不符合条件的怪兽）。
function c58901502.cfilter(c)
	return c:IsFacedown() or not (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO))
end
-- 效果①的发动条件判定函数。
function c58901502.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在不符合条件的怪兽，若不存在（即自己场上的怪兽只有战士族·地属性的同调怪兽），则满足发动条件。
	return not Duel.IsExistingMatchingCard(c58901502.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：额外卡组中卡名为「御用防御者」、可以特殊召唤，且额外怪兽区域有空位可供其特殊召唤的卡。
function c58901502.spfilter(c,e,tp)
	-- 检查卡片是否为「御用防御者」、是否能被特殊召唤，以及额外怪兽区域是否有可用空位。
	return c:IsCode(58901502) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动准备（Target）函数。
function c58901502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查额外卡组是否存在至少1只满足特殊召唤条件的「御用防御者」。
	if chk==0 then return Duel.IsExistingMatchingCard(c58901502.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理（Operation）函数。
function c58901502.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「御用防御者」。
	local g=Duel.SelectMatchingCard(tp,c58901502.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的效果处理（Operation）函数，为自身添加攻击力上升的效果。
function c58901502.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到那次伤害步骤结束时上升这张卡以外的自己场上的战士族·地属性的同调怪兽数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(c58901502.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：表侧表示的战士族·地属性的同调怪兽。
function c58901502.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 计算攻击力上升数值的函数。
function c58901502.atkval(e,c)
	-- 计算自己场上除这张卡以外的战士族·地属性同调怪兽的数量，并乘以1000作为攻击力上升值。
	return Duel.GetMatchingGroupCount(c58901502.filter,c:GetControler(),LOCATION_MZONE,0,e:GetHandler())*1000
end
