--ダーク・ヴァージャー
-- 效果：
-- 自己场上有植物族的调整召唤时，这张卡可以从墓地攻击表示特殊召唤。
function c50164989.initial_effect(c)
	-- 自己场上有植物族的调整召唤时，这张卡可以从墓地攻击表示特殊召唤。
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
-- 检测本次成功召唤的怪兽是否为自己场上、种族为植物族且为调整怪兽，满足才允许本效果发动。
function c50164989.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsRace(RACE_PLANT) and tc:IsType(TYPE_TUNER)
end
-- 效果发动时点检查己方主要怪兽区是否有可用空格，且墓地的这张卡是否能够以表侧攻击表示进行特殊召唤。
function c50164989.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方主要怪兽区存在至少1个可用空格，用于放置特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 将本次连锁的处理信息登记为特殊召唤效果，对象为这张卡自身，数量为1，以便其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段，若这张卡仍与效果保持关联，则将其以表侧攻击表示特殊召唤到己方场上。
function c50164989.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：这张卡以表侧攻击表示从墓地特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
