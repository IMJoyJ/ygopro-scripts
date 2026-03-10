--ダーク・ヴァージャー
-- 效果：
-- 自己场上有植物族的调整召唤时，这张卡可以从墓地攻击表示特殊召唤。
function c50164989.initial_effect(c)
	-- 效果原文内容：自己场上有植物族的调整召唤时，这张卡可以从墓地攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50164989,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c50164989.spcon)
	e1:SetTarget(c50164989.sptg)
	e1:SetOperation(c50164989.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断发动效果的召唤是否为玩家控制的植物族调整怪兽
function c50164989.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsRace(RACE_PLANT) and tc:IsType(TYPE_TUNER)
end
-- 规则层面作用：检测是否满足特殊召唤条件，包括场上是否有空位和自身能否被特殊召唤
function c50164989.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 规则层面作用：设置连锁操作信息，表明将要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行特殊召唤操作，将卡片以攻击表示特殊召唤到场上
function c50164989.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面作用：将卡片以攻击表示特殊召唤到玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
