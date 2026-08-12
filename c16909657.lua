--レプティレス・スキュラ
-- 效果：
-- 这张卡战斗破坏攻击力0的怪兽的场合，可以把那只怪兽从墓地在自己场上表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c16909657.initial_effect(c)
	-- 诱发选发效果，战斗破坏攻击力为0的怪兽时可以发动
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
-- 效果发动条件：自身参与了战斗且战斗破坏的怪兽攻击力为0
function c16909657.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:GetPreviousAttackOnField()==0
end
-- 效果处理条件：自身场上的怪兽区有空位且战斗破坏的怪兽在墓地可以特殊召唤
function c16909657.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	-- 检查自身场上的怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	tc:CreateEffectRelation(e)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果处理流程：将战斗破坏的怪兽从墓地特殊召唤到自己场上
function c16909657.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 确认战斗破坏的怪兽存在于场上且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
