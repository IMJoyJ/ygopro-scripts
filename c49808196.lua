--メタボ・サッカー
-- 效果：
-- 把这张卡解放对暗属性怪兽的上级召唤成功时，在自己场上把3只「代谢衍生物」（暗·1星·恶魔族·攻0/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c49808196.initial_effect(c)
	-- 创建一个诱发必发效果，当此卡因上级召唤被作为素材时发动
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
-- 效果条件：此卡因上级召唤被作为素材，且其解放的怪兽为暗属性
function c49808196.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SUMMON and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 效果处理：设置操作信息，表示将特殊召唤3只衍生物
function c49808196.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将生成3只「代谢衍生物」
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置操作信息，表示将特殊召唤3只「代谢衍生物」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理函数：检测是否受【青眼精灵龙】影响、判断场上是否有足够空间、判断是否可以特殊召唤衍生物，并循环执行特殊召唤与赋予效果
function c49808196.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断玩家场上是否有至少3个空怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 判断玩家是否可以特殊召唤指定的「代谢衍生物」
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,49808197,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	for i=1,3 do
		-- 创建一张ID为49808197的衍生物卡片
		local token=Duel.CreateToken(tp,49808197)
		-- 将该衍生物以守备表示特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 为衍生物赋予不能作为上级召唤祭品的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	-- 完成本次特殊召唤流程
	Duel.SpecialSummonComplete()
end
