--ドッペル・ウォリアー
-- 效果：
-- ①：从自己墓地有怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「二重身衍生物」（战士族·暗·1星·攻/守400）攻击表示特殊召唤。
function c53855409.initial_effect(c)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53855409,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c53855409.spcon)
	e1:SetTarget(c53855409.sptg)
	e1:SetOperation(c53855409.spop)
	c:RegisterEffect(e1)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53855409,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c53855409.tcon)
	e2:SetTarget(c53855409.ttg)
	e2:SetOperation(c53855409.top)
	c:RegisterEffect(e2)
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.gfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53855409.gfilter,1,nil,tp)
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.tcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function c53855409.top(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 执行对应的效果条件检查或辅助函数处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 执行对应的效果条件检查或辅助函数处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then return end
	for i=1,2 do
		-- 执行对应的效果条件检查或辅助函数处理
		local token=Duel.CreateToken(tp,53855409+i)
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SpecialSummonComplete()
end
