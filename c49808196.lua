--メタボ・サッカー
-- 效果：
-- 把这张卡解放对暗属性怪兽的上级召唤成功时，在自己场上把3只「代谢衍生物」（暗·1星·恶魔族·攻0/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c49808196.initial_effect(c)
	-- 把这张卡解放对暗属性怪兽的上级召唤成功时，在自己场上把3只「代谢衍生物」（暗·1星·恶魔族·攻0/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49808196,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c49808196.tkcon)
	e1:SetTarget(c49808196.tktg)
	e1:SetOperation(c49808196.tkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡因上级召唤而被解放，且那次上级召唤出的怪兽是暗属性。
function c49808196.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SUMMON and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 效果发动时的目标处理：无需选择对象，直接允许发动，并登记本次效果将特殊召唤3只衍生物。
function c49808196.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果将生成3只衍生物（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 登记操作信息：本效果将进行3只怪兽的特殊召唤（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理时的操作：先检查【青眼精灵龙】的封锁与怪兽区空格；若可特召，则在己方场上以表侧守备表示特殊召唤3只「代谢衍生物」，并为每只衍生物赋予“不能为上级召唤而解放”的永续效果，最后完成特殊召唤。
function c49808196.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查己方怪兽区域可用空格是否不少于3个，若不足则无法特殊召唤3只衍生物，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 确认己方玩家当前能否将「代谢衍生物」（暗·1星·恶魔族·攻0/守0）以表侧守备表示特殊召唤，若不能则结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,49808197,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	for i=1,3 do
		-- 生成1只卡号为49808197的「代谢衍生物」，控制者为效果发动玩家。
		local token=Duel.CreateToken(tp,49808197)
		-- 将衍生物以表侧守备表示特殊召唤到己方场上，这是连续特殊召唤处理中的一步。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 对应效果原文：「这衍生物不能为上级召唤而解放。」
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	-- 完成连续特殊召唤处理，使上述步骤特殊召唤的衍生物正式上场并触发相关时点。
	Duel.SpecialSummonComplete()
end
