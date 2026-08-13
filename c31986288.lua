--スプリット・D・ローズ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以在自己场上把2只「魔界蔷薇衍生物」（植物族·暗·3星·攻/守1200）特殊召唤。
function c31986288.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以在自己场上把2只「魔界蔷薇衍生物」（植物族·暗·3星·攻/守1200）特殊召唤。
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
-- 发动条件判定：这张卡因战斗被破坏并送去墓地时，效果才能发动，因此须检查该卡当前位于墓地且破坏原因为战斗。
function c31986288.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 发动时判定：若己方不受青眼精灵龙『不能同时特殊召唤2只以上怪兽』效果影响，且己方主要怪兽区空位多于1个，且己方可以特殊召唤魔界蔷薇衍生物，则效果满足发动条件，并登记操作信息。
function c31986288.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求己方主要怪兽区空余位置大于1，因为本效果需要特殊召唤2只衍生物，至少要有2个可用怪兽格子。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查己方是否能够将卡号31986289的「魔界蔷薇衍生物」作为怪兽（植物族、暗、3星、攻/守1200）以表侧表示特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31986289,0,TYPES_TOKEN_MONSTER,1200,1200,3,RACE_PLANT,ATTRIBUTE_DARK) end
	-- 登记本次连锁中会生成2只衍生物的操作信息，用于系统识别衍生物相关效果（如禁止特殊召唤衍生物的卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 登记本次连锁中会特殊召唤2只怪兽的操作信息，与CATEGORY_TOKEN配合，使系统能够检测并响应这次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理阶段：再次确认青眼精灵龙的限制不存在、己方有足够格子且可以特殊召唤衍生物，然后依次创建并特殊召唤2只魔界蔷薇衍生物，最后完成特殊召唤处理。
function c31986288.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若己方主要怪兽区空位少于2个，则无法特殊召唤2只衍生物，本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 若己方当前不能将魔界蔷薇衍生物特殊召唤，则本次效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,31986289,0,TYPES_TOKEN_MONSTER,1200,1200,3,RACE_PLANT,ATTRIBUTE_DARK) then return end
	for i=1,2 do
		-- 创建1只卡号31986289的「魔界蔷薇衍生物」到己方场上，作为待特殊召唤的衍生物。
		local token=Duel.CreateToken(tp,31986289)
		-- 将衍生物以表侧表示特殊召唤到己方场上（此步骤为分解式特殊召唤，供连续特殊召唤多只使用）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 结束特殊召唤的分解处理，正式完成全部衍生物的特殊召唤。
	Duel.SpecialSummonComplete()
end
