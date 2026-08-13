--アイヴィ・ウォール
-- 效果：
-- 反转：在对方场上把1只「常春藤衍生物」（地·1星·植物族·攻/守0）守备表示特殊召唤。「常春藤衍生物」被破坏时，这衍生物的控制者受到300分伤害。
function c30069398.initial_effect(c)
	-- 反转：在对方场上把1只「常春藤衍生物」（地·1星·植物族·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30069398,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetTarget(c30069398.target)
	e1:SetOperation(c30069398.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时无额外条件，允许发动；同时设置操作信息：本连锁将生成1只衍生物并特殊召唤1只怪兽，具体目标在处理时确定。
function c30069398.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含生成1只衍生物，目标玩家暂不指定，供其他效果参考。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果包含将1只怪兽特殊召唤，目标玩家暂不指定，供其他效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：若对方怪兽区有空位且可特召衍生物，则创建并特殊召唤「常春藤衍生物」到对方场上，并在特召成功后为该衍生物注册破坏伤害效果，最后完成特殊召唤流程。
function c30069398.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上主要怪兽区域是否有空位；若无空位则无法特殊召唤，直接结束效果处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 检查当前玩家是否能够将1只地属性·1星·植物族·攻击力0/守备力0的衍生物以表侧守备表示特殊召唤到对方场上；若受到特殊召唤限制则无法处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,30069399,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then return end
	-- 创建1只「常春藤衍生物」（卡号30069399）的衍生物，持有者为效果发动者。
	local token=Duel.CreateToken(tp,30069399)
	-- 作为分步特殊召唤的一步，将衍生物以表侧守备表示特殊召唤到对方场上；若成功，则继续为该衍生物注册离场伤害效果。
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
		-- 「常春藤衍生物」被破坏时，这衍生物的控制者受到300分伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(c30069398.damop)
		token:RegisterEffect(e1,true)
	end
	-- 结束分步特殊召唤流程，无论是否成功召唤都调用，以触发特殊召唤成功/失败的时点并处理相关诱发效果。
	Duel.SpecialSummonComplete()
end
-- 衍生物离场时点处理：若衍生物是被破坏离场，则给予其离场前的控制者300点效果伤害，随后重置自身效果，确保该效果只处理一次。
function c30069398.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 对衍生物离场前的控制者造成300点伤害，伤害类型为效果伤害（REASON_EFFECT）。
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end
