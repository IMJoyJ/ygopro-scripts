--ジュラック・スタウリコ
-- 效果：
-- 这张卡被战斗破坏的场合，在自己场上把2只「朱罗纪衍生物」（恐龙族·炎·1星·攻0/守0）守备表示特殊召唤。这衍生物不能为名字带有「朱罗纪」的怪兽以外的上级召唤而解放。
function c48411996.initial_effect(c)
	-- 这张卡被战斗破坏的场合，在自己场上把2只「朱罗纪衍生物」（恐龙族·炎·1星·攻0/守0）守备表示特殊召唤。这衍生物不能为名字带有「朱罗纪」的怪兽以外的上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48411996,0))  --"特殊召唤Token"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c48411996.target)
	e1:SetOperation(c48411996.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判定：本效果没有发动条件，直接允许发动；同时登记了后续特殊召唤2只衍生物的操作信息，供连锁处理时判断。
function c48411996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本连锁的操作信息登记为『特殊召唤衍生物』（CATEGORY_TOKEN）：预计特殊召唤2只衍生物，对象不确定，属于tp玩家，用于配合其他卡片效果的时点判定。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	-- 将本连锁的操作信息登记为『特殊召唤』（CATEGORY_SPECIAL_SUMMON）：预计进行2只怪兽的特殊召唤，对象不确定，属于tp玩家，供连锁处理时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- 效果处理：若「青眼精灵龙」的效果适用则终止；若自己的怪兽区空格不足2个或无法特殊召唤该衍生物则终止；否则连续生成2只「朱罗纪衍生物」并以表侧守备表示特殊召唤，同时为每只衍生物赋予『不能为名字带有「朱罗纪」的怪兽以外的上级召唤而解放』的永续效果，最后完成特殊召唤处理。
function c48411996.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查tp玩家怪兽区是否有至少2个可用空格；若不足2个则无法特殊召唤2只衍生物，效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查tp玩家是否可将「朱罗纪衍生物」（恐龙族·炎·1星·攻0/守0）以表侧守备表示特殊召唤；若因任何限制不能特殊召唤，则效果处理中止。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,48411997,0x22,TYPES_TOKEN_MONSTER,0,0,1,RACE_DINOSAUR,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 在tp玩家场上创建1只「朱罗纪衍生物」（卡号48411997）的衍生物实体，等待进行特殊召唤。
		local token=Duel.CreateToken(tp,48411997)
		-- 将创建的衍生物以表侧守备表示特殊召唤到tp场上（进入特殊召唤步骤，暂未正式登场）；同时检查召唤条件及苏生限制。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这衍生物不能为名字带有「朱罗纪」的怪兽以外的上级召唤而解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(c48411996.sumlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	-- 完成所有SpecialSummonStep组成的连续特殊召唤，正式让衍生物登场并触发特殊召唤成功时的相关时点。
	Duel.SpecialSummonComplete()
end
-- 判定衍生物的解放限制：当衍生物被作为上级召唤的解放素材时，若将要上级召唤的怪兽不带有「朱罗纪」字段，则不能解放；反之则可以。
function c48411996.sumlimit(e,c)
	return not c:IsSetCard(0x22)
end
