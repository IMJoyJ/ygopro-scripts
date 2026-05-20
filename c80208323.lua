--異界の棘紫獣
-- 效果：
-- 这张卡在墓地存在，自己场上的怪兽被战斗破坏送去墓地时，这张卡可以从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。「异界的棘紫兽」的效果1回合只能发动1次。
function c80208323.initial_effect(c)
	-- 这张卡在墓地存在，自己场上的怪兽被战斗破坏送去墓地时，这张卡可以从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。「异界的棘紫兽」的效果1回合只能发动1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80208323,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,80208323)
	e1:SetCondition(c80208323.spcon)
	e1:SetTarget(c80208323.sptg)
	e1:SetOperation(c80208323.spop)
	c:RegisterEffect(e1)
end
-- 过滤被战斗破坏送去墓地的自己场上的怪兽
function c80208323.spfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 检查被战斗破坏送去墓地的怪兽中是否包含自己场上的怪兽，且不包含自身
function c80208323.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c80208323.spfilter,1,nil,tp)
end
-- 特殊召唤效果的发动条件与对象选择检测
function c80208323.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将自身特殊召唤，并注册离场时除外的效果
function c80208323.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍存在于墓地，则将自身特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
