--インフェルニティ・リベンジャー
-- 效果：
-- 这张卡在墓地存在，自己手卡是0张的场合，「永火复仇者」以外的自己场上存在的怪兽被和对方怪兽的战斗破坏送去墓地时，这张卡可以从墓地特殊召唤。这个效果特殊召唤的这张卡的等级变成和对方怪兽破坏的自己怪兽相同等级。
function c85475641.initial_effect(c)
	-- 这张卡在墓地存在，自己手卡是0张的场合，「永火复仇者」以外的自己场上存在的怪兽被和对方怪兽的战斗破坏送去墓地时，这张卡可以从墓地特殊召唤。这个效果特殊召唤的这张卡的等级变成和对方怪兽破坏的自己怪兽相同等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85475641,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c85475641.spcon)
	e1:SetTarget(c85475641.sptg)
	e1:SetOperation(c85475641.spop)
	c:RegisterEffect(e1)
end
-- 过滤被战斗破坏送去墓地的、除「永火复仇者」以外的、原本控制者和当前控制者均为自己的、等级大于0的怪兽
function c85475641.filter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:GetLevel()>0
		and c:IsControler(tp) and c:IsPreviousControler(tp) and not c:IsCode(85475641)
end
-- 判断是否有符合条件的自己怪兽被战斗破坏送去墓地，记录该怪兽的等级，并确认自己手牌是否为0张
function c85475641.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c85475641.filter,nil,tp)
	local tc=g:GetFirst()
	if tc then
		e:SetLabel(tc:GetLevel())
		-- 检查自己手牌数量是否为0
		return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
	else return false end
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c85475641.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，在满足手牌为0且自身仍在墓地等条件时，将自身特殊召唤并改变等级
function c85475641.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查自己手牌是否仍为0张，以及此卡是否仍存在于墓地，若不满足则结束效果处理
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 or not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上（特殊召唤的第一步）
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	-- 这个效果特殊召唤的这张卡的等级变成和对方怪兽破坏的自己怪兽相同等级。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
