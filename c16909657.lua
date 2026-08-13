--レプティレス・スキュラ
-- 效果：
-- 这张卡战斗破坏攻击力0的怪兽的场合，可以把那只怪兽从墓地在自己场上表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c16909657.initial_effect(c)
	-- 这张卡战斗破坏攻击力0的怪兽的场合，可以把那只怪兽从墓地在自己场上表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16909657,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c16909657.spcon)
	e2:SetTarget(c16909657.sptg)
	e2:SetOperation(c16909657.spop)
	c:RegisterEffect(e2)
end
-- 判定触发条件：本卡与战斗对象仍存在战斗关联，且被战斗破坏的怪兽在场上时攻击力为0，满足“战斗破坏攻击力0的怪兽的场合”。
function c16909657.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:GetPreviousAttackOnField()==0
end
-- 特殊召唤对象的合法性判定：将战斗对象作为候选，检查自己场上是否有可用主要怪兽区，且该对象在墓地并能以表侧守备表示特殊召唤。
function c16909657.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	-- 检查自己场上是否有空余的主要怪兽区域，作为能否从墓地特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	tc:CreateEffectRelation(e)
	-- 设置操作信息：本次效果处理确定为特殊召唤，对象为被战斗破坏的怪兽，数量1，用于连锁与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果处理：若战斗对象仍与效果关联，则将其以表侧守备表示特殊召唤；成功时，为那只怪兽附加两个使效果无效化的效果（怪兽效果无效与效果无效化）。
function c16909657.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 判断战斗对象是否仍与此效果关联，且特殊召唤是否成功（返回特殊召唤数量不为0）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
