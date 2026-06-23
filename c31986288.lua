--スプリット・D・ローズ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以在自己场上把2只「魔界蔷薇衍生物」（植物族·暗·3星·攻/守1200）特殊召唤。
function c31986288.initial_effect(c)
	-- 创建一个诱发选发效果，当此卡被战斗破坏送去墓地时发动，效果描述为“特殊召唤”，分类为特殊召唤和衍生物，效果代码为被战斗破坏送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31986288,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c31986288.condition)
	e1:SetTarget(c31986288.target)
	e1:SetOperation(c31986288.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡在墓地且被战斗破坏
function c31986288.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果处理条件检测：玩家未被【青眼精灵龙】效果影响、场上怪兽区有2个以上空位、可以特殊召唤衍生物
function c31986288.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上怪兽区是否有2个以上空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31986289,0,TYPES_TOKEN_MONSTER,1200,1200,3,RACE_PLANT,ATTRIBUTE_DARK) end
	-- 设置操作信息：将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理函数：检测是否可以发动，若可以则召唤2只衍生物
function c31986288.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上怪兽区是否至少有2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检测是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,31986289,0,TYPES_TOKEN_MONSTER,1200,1200,3,RACE_PLANT,ATTRIBUTE_DARK) then return end
	for i=1,2 do
		-- 创建一张指定编号的衍生物
		local token=Duel.CreateToken(tp,31986289)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
