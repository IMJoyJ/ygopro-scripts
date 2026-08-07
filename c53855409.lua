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
-- 过滤筛选原本类型为怪兽且从自己墓地特殊召唤成功的卡。
function c53855409.gfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ①效果的发动条件：检查触发事件中是否有怪兽从自己墓地特殊召唤。
function c53855409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53855409.gfilter,1,nil,tp)
end
-- ①效果的Target逻辑：检查怪兽区是否有空位以及自身能否从手卡特殊召唤。
function c53855409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为将手卡的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：将手卡的这张卡表侧表示特殊召唤到场上。
function c53855409.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：检查这张卡是否在墓地且是因为作为同调素材而被送去墓地。
function c53855409.tcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果的Target逻辑：检查是否不受青眼精灵龙限制、怪兽区是否有2个以上空位以及是否能生成特招衍生物。
function c53855409.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少2个空余的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能够特殊召唤对应的「二重身衍生物」（战士族·暗·1星·攻/守400·攻击表示）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置连锁的操作信息为生成2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁的操作信息为特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②效果的处理函数：检查场地与召唤条件，生成2只「二重身衍生物」并攻击表示特殊召唤到场上。
function c53855409.top(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上怪兽区域空格是否少于2个，若是则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查玩家此时是否仍能特殊召唤「二重身衍生物」，若不能则中断处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then return end
	for i=1,2 do
		-- 创建代号为53855410（二重身衍生物）的衍生物卡片对象。
		local token=Duel.CreateToken(tp,53855409+i)
		-- 将创建的衍生物表侧攻击表示特殊召唤到场上（分步特招）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 完成衍生物分步特殊召唤的处理流程。
	Duel.SpecialSummonComplete()
end
