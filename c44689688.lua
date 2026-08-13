--ジュラック・スピノス
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，在对方场上把1只「棘龙衍生物」（恐龙族·炎·1星·攻300/守0）攻击表示特殊召唤。
function c44689688.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，在对方场上把1只「棘龙衍生物」（恐龙族·炎·1星·攻300/守0）攻击表示特殊召唤。
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
-- 触发条件判定：本次被战斗破坏送去墓地的怪兽只有1只，且该怪兽是被这张卡战斗破坏并因此送去墓地；满足则条件成立。
function c44689688.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 发动准备：无取对象效果；在发动时允许发动，并设置本次处理涉及特殊召唤和衍生物生成的操作信息。
function c44689688.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将进行特殊召唤，预定数量为1；因具体怪兽在效果处理时才确定，所以对象记为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：本次效果将生成衍生物，预定数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果处理：先检查对方怪兽区域是否有可用空格以及能否特殊召唤衍生物；若可以，则生成「棘龙衍生物」并攻击表示特殊召唤到对方场上。
function c44689688.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上主要怪兽区域是否有空格；若无空格则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 then return end
	-- 检查玩家tp能否将一只恐龙族·炎属性·1星·攻击力300/守备力0的「棘龙衍生物」以表侧攻击表示特殊召唤到对方（1-tp）场上。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,44689689,0,TYPES_TOKEN_MONSTER,300,0,1,RACE_DINOSAUR,ATTRIBUTE_FIRE,POS_FACEUP_ATTACK,1-tp) then
		-- 创建1只卡号为44689689的「棘龙衍生物」衍生物，控制者为tp。
		local token=Duel.CreateToken(tp,44689689)
		-- 将生成的衍生物以表侧攻击表示特殊召唤到对方（1-tp）场上，由tp作为特殊召唤玩家。
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
