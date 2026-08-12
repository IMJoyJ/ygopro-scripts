--雲魔物－羊雲
-- 效果：
-- 这张卡被战斗破坏送去墓地时，在自己场上把2只「云魔物衍生物」（天使族·水·1星·攻/守0）守备表示特殊召唤。这些衍生物不能作为名字带有「云魔物」的卡以外的祭品召唤的祭品。
function c56597272.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，在自己场上把2只「云魔物衍生物」（天使族·水·1星·攻/守0）守备表示特殊召唤。这些衍生物不能作为名字带有「云魔物」的卡以外的祭品召唤的祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56597272,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c56597272.condition)
	e1:SetTarget(c56597272.target)
	e1:SetOperation(c56597272.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否被战斗破坏并送去墓地
function c56597272.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 特殊召唤效果的发动准备，设置产生衍生物和特殊召唤的操作信息
function c56597272.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：产生2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 特殊召唤2只「云魔物衍生物」并为它们添加不能作为「云魔物」以外卡片的上级召唤祭品的限制
function c56597272.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的怪兽区域空位数是否小于2，若不足2个空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查玩家是否可以特殊召唤符合「云魔物衍生物」各项数值的怪兽
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,56597273,0x18,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 创建一张「云魔物衍生物」卡片
		local token=Duel.CreateToken(tp,56597273)
		-- 将衍生物以表侧守备表示特殊召唤到自己场上（单步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这些衍生物不能作为名字带有「云魔物」的卡以外的祭品召唤的祭品。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c56597272.sumlimit)
		token:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 限制不能作为名字带有「云魔物」的卡以外的祭品召唤的祭品
function c56597272.sumlimit(e,c)
	return not c:IsSetCard(0x18)
end
