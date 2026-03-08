--ジュラック・スピノス
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，在对方场上把1只「棘龙衍生物」（恐龙族·炎·1星·攻300/守0）攻击表示特殊召唤。
function c44689688.initial_effect(c)
	-- 效果原文：这张卡战斗破坏对方怪兽送去墓地时，在对方场上把1只「棘龙衍生物」（恐龙族·炎·1星·攻300/守0）攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44689688,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c44689688.spcon)
	e1:SetTarget(c44689688.sptg)
	e1:SetOperation(c44689688.spop)
	c:RegisterEffect(e1)
end
-- 规则层面：判断是否为1只怪兽被战斗破坏送入墓地，且该怪兽是由这张卡造成的破坏。
function c44689688.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 规则层面：设置连锁处理信息，表示将特殊召唤1只衍生物。
function c44689688.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置连锁处理信息，表示将特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 规则层面：设置连锁处理信息，表示将生成1个棘龙衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 规则层面：检查对方场上是否有空位，以及是否可以特殊召唤该衍生物。
function c44689688.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：如果对方场上没有空位则不执行效果。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 then return end
	-- 规则层面：检查玩家是否可以特殊召唤该衍生物。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,44689689,0,TYPES_TOKEN_MONSTER,300,0,1,RACE_DINOSAUR,ATTRIBUTE_FIRE,POS_FACEUP_ATTACK,1-tp) then
		-- 规则层面：创建一个棘龙衍生物。
		local token=Duel.CreateToken(tp,44689689)
		-- 规则层面：将创建的棘龙衍生物以攻击表示特殊召唤到对方场上。
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
