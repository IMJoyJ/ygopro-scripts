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
-- 特殊召唤怪兽过滤条件：原本是怪兽且原本控制者为当前玩家、从自己墓地特殊召唤
function c53855409.gfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ①效果发动条件：确认是否从自己墓地有怪兽被特殊召唤
function c53855409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53855409.gfilter,1,nil,tp)
end
-- ①效果发动准备/检查：确认主要怪兽区域有空位且自身可以特殊召唤
function c53855409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将自身表侧表示特殊召唤
function c53855409.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果发动条件：此卡在墓地存在且作为同调素材送去墓地
function c53855409.tcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果发动准备/检查：确认不受精灵龙限制、主要怪兽区空位足够且可特殊召唤衍生物
function c53855409.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查主要怪兽区域空位是否大于1个
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤「二重身衍生物」（战士族·暗·1星·攻/守400）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置连锁操作信息：生成2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁操作信息：特殊召唤2张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②效果处理：在自己场上攻击表示特殊召唤2只「二重身衍生物」
function c53855409.top(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时检查主要怪兽区域空位是否不足2个
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时检查玩家是否可以特殊召唤该衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,53855410,0,TYPES_TOKEN_MONSTER,400,400,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then return end
	for i=1,2 do
		-- 生成「二重身衍生物」卡片对象
		local token=Duel.CreateToken(tp,53855409+i)
		-- 执行单张衍生物的表侧攻击表示特殊召唤步骤
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 完成所有衍生物的特殊召唤处理
	Duel.SpecialSummonComplete()
end
