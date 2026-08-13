--ブラック・リベンジ
-- 效果：
-- ①：自己场上的鸟兽族怪兽被战斗破坏送去墓地时才能发动。在自己场上把2只「黑羽-黑冠衍生物」（鸟兽族·暗·2星·攻0/守800）特殊召唤。
function c9925982.initial_effect(c)
	-- ①：自己场上的鸟兽族怪兽被战斗破坏送去墓地时才能发动。在自己场上把2只「黑羽-黑冠衍生物」（鸟兽族·暗·2星·攻0/守800）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c9925982.condition)
	e1:SetTarget(c9925982.target)
	e1:SetOperation(c9925982.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：判断作为事件对象的怪兽是否是被战斗破坏后送入墓地、且原本控制者为己方、种族为鸟兽族，用于确定是否满足发动条件。
function c9925982.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsRace(RACE_WINDBEAST)
end
-- 发动条件判定：在战斗破坏怪兽的事件组中，只要存在至少1只满足上述筛选条件的己方鸟兽族怪兽被战斗破坏送去墓地，即可发动本卡。
function c9925982.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9925982.cfilter,1,nil,tp)
end
-- 发动时合法性检测：己方未受【青眼精灵龙】效果影响（即允许同时特殊召唤2只以上），且己方怪兽区域可用空格数大于1，且能够特殊召唤‘黑羽-黑冠衍生物’。
function c9925982.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方场上可用的怪兽区域空格数是否大于1，确保能放置2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查己方是否能够将‘黑羽-黑冠衍生物’（卡号9925983，鸟兽族·暗·2星·攻0/守800）以表侧表示特殊召唤到己方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,9925983,0,TYPES_TOKEN_MONSTER,0,800,2,RACE_WINDBEAST,ATTRIBUTE_DARK) end
	-- 设置操作信息：声明本效果将生成2只衍生物（CATEGORY_TOKEN），供后续卡牌效果互动与规则判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：声明本效果将进行2只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON），对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若【青眼精灵龙】效果仍适用则终止；否则在空位足够且能特殊召唤衍生物的前提下，循环2次创建‘黑羽-黑冠衍生物’并通过特殊召唤步骤将其特殊召唤，最后完成特殊召唤。
function c9925982.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次确认己方场上可用怪兽区域空格数大于1（用于实际特招2只衍生物）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 再次确认己方能够特殊召唤‘黑羽-黑冠衍生物’，满足条件才执行后续特殊召唤操作。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,9925983,0,TYPES_TOKEN_MONSTER,0,800,2,RACE_WINDBEAST,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 生成1只‘黑羽-黑冠衍生物’（token，卡号9925983）作为待特殊召唤的怪兽。
			local token=Duel.CreateToken(tp,9925983)
			-- 将衍生物以表侧表示加入特殊召唤处理步骤（sumtype=0，特殊召唤到己方场上），作为连续特殊召唤的其中一只。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成连续特殊召唤处理，实际将2只衍生物特殊召唤到己方场上。
		Duel.SpecialSummonComplete()
	end
end
