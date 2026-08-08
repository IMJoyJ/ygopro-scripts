--ドッペル・ウォリアー
-- 效果：
-- ①：从自己墓地有怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「二重身衍生物」（战士族·暗·1星·攻/守400）攻击表示特殊召唤。
function c53855409.initial_effect(c)
	-- ①：从自己墓地有怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。在自己场上把2只「二重身衍生物」（战士族·暗·1星·攻/守400）攻击表示特殊召唤。
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
-- 过滤从自己墓地特殊召唤的怪兽
function c53855409.gfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 检查触发事件中是否存在从自己墓地特殊召唤的怪兽
function c53855409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53855409.gfilter,1,nil,tp)
end
-- 特殊召唤效果的Target函数，检查自己场上有空余怪兽区域且自身可以特殊召唤
function c53855409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation函数，若自身依然与效果相关则将自身特殊召唤
function c53855409.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检查自身是否在墓地且作为同调素材被送去墓地
function c53855409.tcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 特殊召唤衍生物效果的Target函数，检查未受效果限制、自己场上有至少2个空余怪兽区域且能够特殊召唤衍生物
function c53855409.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少2个可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能够以攻击表示特殊召唤「二重身衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置当前连锁的操作信息为生成2张衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置当前连锁的操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 特殊召唤衍生物效果的Operation函数，在满足条件时在自己场上攻击表示特殊召唤2只「二重身衍生物」
function c53855409.top(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的可用怪兽区域不足2个则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 若无法特殊召唤「二重身衍生物」则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then return end
	for i=1,2 do
		-- 生成1张「二重身衍生物」代牌对象
		local token=Duel.CreateToken(tp,53855409+i)
		-- 将衍生物以表侧攻击表示分步特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 完成分步特殊召唤流程
	Duel.SpecialSummonComplete()
end
