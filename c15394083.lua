--極星獣タングリスニ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。在自己场上把2只「极星兽衍生物」（兽族·地·3星·攻/守0）特殊召唤。
function c15394083.initial_effect(c)
	-- 创建效果e1，设置为触发效果，对应被战斗破坏送去墓地时发动
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
-- 效果发动条件：此卡在墓地且因战斗破坏
function c15394083.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置效果目标：准备特殊召唤2只衍生物
function c15394083.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：将要特殊召唤2只衍生物（重复）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理流程：检查是否受青眼精灵龙影响、是否有足够空间、是否可特殊召唤衍生物，然后执行特殊召唤
function c15394083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有至少2个空怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15394084,0x6042,TYPES_TOKEN_MONSTER,0,0,3,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		-- 创建一张指定编号的衍生物卡片
		local token=Duel.CreateToken(tp,15394084)
		-- 特殊召唤一张衍生物到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
