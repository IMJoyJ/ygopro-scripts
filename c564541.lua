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
-- 判断进行上级召唤的怪兽是否为龙族怪兽
function c564541.dccon(e,c)
	return c:IsRace(RACE_DRAGON)
end
-- 过滤出墓地中龙族以外的怪兽卡
function c564541.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_DRAGON)
end
-- 特殊召唤效果的发动条件判断
function c564541.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合，且自己场上没有怪兽存在
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判断自己墓地中是否不存在龙族以外的怪兽
		and not Duel.IsExistingMatchingCard(c564541.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤效果的靶向与可行性检测
function c564541.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，并在成功特殊召唤后适用离场除外的效果
function c564541.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，验证自身卡片是否仍关联此效果，且自己场上依然没有怪兽
	if c:IsRelateToEffect(e) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 效果处理时，验证自己墓地中是否依然不存在龙族以外的怪兽
		and not Duel.IsExistingMatchingCard(c564541.cfilter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 将自身以表侧攻击表示特殊召唤
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
