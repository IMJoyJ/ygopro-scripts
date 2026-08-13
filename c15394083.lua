--極星獣タングリスニ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。在自己场上把2只「极星兽衍生物」（兽族·地·3星·攻/守0）特殊召唤。
function c15394083.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。在自己场上把2只「极星兽衍生物」（兽族·地·3星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15394083,0))  --"特殊召唤Token"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c15394083.condition)
	e1:SetTarget(c15394083.target)
	e1:SetOperation(c15394083.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判断：效果持有者这张卡必须位于墓地，且被战斗破坏；即满足‘这张卡被战斗破坏送去墓地的场合’。
function c15394083.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 发动时的目标处理：本效果不需要取对象，合法即允许发动；同时登记本效果将涉及2只衍生物的特殊召唤，供连锁判定使用。
function c15394083.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果会生成2只衍生物（分类CATEGORY_TOKEN），用于让星尘龙、王家长眠之谷等卡正确识别连锁内容。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 登记操作信息：本效果会特殊召唤2只怪兽（分类CATEGORY_SPECIAL_SUMMON），用于让相关效果正确判断这次连锁是否包含特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：先进行合法性检查（对方青眼精灵龙效果限制、我方怪兽区空格是否足够、是否能特殊召唤衍生物），然后生成2只「极星兽衍生物」并正面表示特殊召唤到我方场上。
function c15394083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查我方主要怪兽区可用空格是否不少于2个；若不足则无法放置2只衍生物，效果处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查当前玩家是否能够特殊召唤设定的「极星兽衍生物」（衍生物·兽族·地·3星·攻/守0），若不能则终止效果处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15394084,0x6042,TYPES_TOKEN_MONSTER,0,0,3,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		-- 创建一只卡号为15394084的「极星兽衍生物」衍生物，作为本次特殊召唤的对象。
		local token=Duel.CreateToken(tp,15394084)
		-- 将衍生物作为连续特殊召唤的一步，表侧表示特殊召唤到我方场上；此步骤暂不正式完成召唤，等待全部衍生物一起处理。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成连续特殊召唤，将之前通过SpecialSummonStep暂存的所有衍生物正式特殊召唤上场。
	Duel.SpecialSummonComplete()
end
