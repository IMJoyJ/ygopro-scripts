--カラクリ兵 弐参六
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的名字带有「机巧」的怪兽表侧攻击表示特殊召唤。
function c3846170.initial_effect(c)
	-- 对应效果原文：『这张卡可以攻击的场合必须作出攻击。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 对应效果原文：『场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。』
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3846170,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c3846170.poscon)
	e3:SetOperation(c3846170.posop)
	c:RegisterEffect(e3)
	-- 对应效果原文：『这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的名字带有「机巧」的怪兽表侧攻击表示特殊召唤。』
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3846170,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCondition(c3846170.spcon)
	e4:SetTarget(c3846170.sptg)
	e4:SetOperation(c3846170.spop)
	c:RegisterEffect(e4)
end
-- poscon 条件函数：判定被选为攻击对象的这张卡当前是否为表侧攻击表示，只有满足此条件时改变表示形式的效果才会发动。
function c3846170.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- posop 处理函数：若这张卡仍表侧表示且与发动时的效果保持关联，则将其表示形式变为表侧守备表示。
function c3846170.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡从当前表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- spcon 条件函数：判定这张卡被战斗破坏后是否位于墓地，且破坏原因是否为战斗破坏，满足才可发动特殊召唤效果。
function c3846170.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- filter 过滤函数：筛选卡组中满足『4星以下、名字带有「机巧」、并能够以表侧攻击表示特殊召唤』的怪兽。
function c3846170.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- sptg 发动目标函数：在发动时检查自己主要怪兽区是否有空位，且卡组中存在符合条件的「机巧」怪兽；满足则允许发动。
function c3846170.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个可用空格，没有空格则无法发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张符合条件的「机巧」怪兽（不取对象，处理时再选择）。
		and Duel.IsExistingMatchingCard(c3846170.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁将进行特殊召唤的操作信息：从卡组特殊召唤1只怪兽，用于后续时点与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- spop 效果处理函数：先确认仍有空位，再提示玩家选择要特殊召唤的怪兽，将其以表侧攻击表示特殊召唤。
function c3846170.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己主要怪兽区是否有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示信息，让玩家从卡组中选择要特殊召唤的「机巧」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选出1张符合条件的「机巧」怪兽（满足4星以下、可特召等），作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c3846170.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上，且不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
