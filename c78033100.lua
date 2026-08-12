--聖刻龍－ドラゴンゲイヴ
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。此外，这张卡被解放时，从自己的手卡·卡组·墓地把1只名字带有「圣刻」的通常怪兽特殊召唤。
function c78033100.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78033100,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c78033100.spcon)
	e1:SetTarget(c78033100.sptg)
	e1:SetOperation(c78033100.spop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	-- 此外，这张卡被解放时，从自己的手卡·卡组·墓地把1只名字带有「圣刻」的通常怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78033100,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(c78033100.sptg)
	e2:SetOperation(c78033100.spop)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
end
-- 检查自身是否在场且与战斗相关，以及被破坏的对方怪兽是否因战斗破坏送去墓地
function c78033100.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的龙族通常怪兽
function c78033100.spfilter1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「圣刻」通常怪兽
function c78033100.spfilter2(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，设置特殊召唤的操作信息
function c78033100.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息（从手卡、卡组、墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 特殊召唤效果的具体处理，根据触发效果选择对应的通常怪兽特殊召唤，并根据效果要求将攻守变为0
function c78033100.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=nil
	if e:GetLabel()==0 then
		-- 从手卡、卡组、墓地（受王家长眠之谷影响）中选择1只满足条件的龙族通常怪兽
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78033100.spfilter1),tp,0x13,0,1,1,nil,e,tp)
	else
		-- 从手卡、卡组、墓地（受王家长眠之谷影响）中选择1只满足条件的「圣刻」通常怪兽
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78033100.spfilter2),tp,0x13,0,1,1,nil,e,tp)
	end
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试将选中的怪兽以表侧表示特殊召唤
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力·守备力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
