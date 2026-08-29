--ミンゲイドラゴン
-- 效果：
-- 龙族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。自己的准备阶段时这张卡在墓地存在，自己场上没有怪兽存在的场合，可以把这张卡表侧攻击表示特殊召唤。这个效果在自己墓地有龙族以外的怪兽存在的场合不能发动。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c564541.initial_effect(c)
	-- 龙族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c564541.dccon)
	c:RegisterEffect(e1)
	-- 自己的准备阶段时这张卡在墓地存在，自己场上没有怪兽存在的场合，可以把这张卡表侧攻击表示特殊召唤。这个效果在自己墓地有龙族以外的怪兽存在的场合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(564541,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c564541.spcon)
	e2:SetTarget(c564541.sptg)
	e2:SetOperation(c564541.spop)
	c:RegisterEffect(e2)
end
-- 判定作为2只解放的条件（上级召唤的怪兽为龙族怪兽）
function c564541.dccon(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_DRAGON) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 过滤墓地中龙族以外的怪兽卡
function c564541.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_DRAGON)
end
-- 特殊召唤效果的发动条件：自己的准备阶段、自己怪兽区没有怪兽且墓地没有龙族以外的怪兽
function c564541.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是否为自己的回合且自己怪兽区没有怪兽
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 确认自己墓地不存在龙族以外的怪兽
		and not Duel.IsExistingMatchingCard(c564541.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤效果的发动目标确认与操作信息设置
function c564541.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理（将自身表侧攻击表示特殊召唤，并赋予离场除外效果）
function c564541.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身与效果有联系且自己怪兽区仍没有怪兽
	if c:IsRelateToEffect(e) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 确认自己墓地仍不存在龙族以外的怪兽
		and not Duel.IsExistingMatchingCard(c564541.cfilter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 将自身表侧攻击表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
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
