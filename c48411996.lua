--ジュラック・スタウリコ
-- 效果：
-- 这张卡被战斗破坏的场合，在自己场上把2只「朱罗纪衍生物」（恐龙族·炎·1星·攻0/守0）守备表示特殊召唤。这衍生物不能为名字带有「朱罗纪」的怪兽以外的上级召唤而解放。
function c48411996.initial_effect(c)
	-- 诱发必发效果，对应一速的【被战斗破坏时】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48411996,0))  --"特殊召唤Token"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c48411996.target)
	e1:SetOperation(c48411996.operation)
	c:RegisterEffect(e1)
end
-- 设置连锁处理信息，确定将特殊召唤2只衍生物
function c48411996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为衍生物特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	-- 设置操作信息为特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- 效果处理函数，执行特殊召唤和设置限制条件
function c48411996.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否有足够的怪兽区域来特殊召唤2只怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,48411997,0x22,TYPES_TOKEN_MONSTER,0,0,1,RACE_DINOSAUR,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 创建一张指定编号的衍生物卡片
		local token=Duel.CreateToken(tp,48411997)
		-- 将衍生物以守备表示形式特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 为衍生物设置不能被解放的效果，限制其只能用于名字带有「朱罗纪」的怪兽上级召唤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(c48411996.sumlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	-- 完成一次特殊召唤流程，确保所有步骤都已处理完毕
	Duel.SpecialSummonComplete()
end
-- 返回值判断是否为名字带有「朱罗纪」的怪兽
function c48411996.sumlimit(e,c)
	return not c:IsSetCard(0x22)
end
