--妖精弓士イングナル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用植物族怪兽的效果特殊召唤成功的场合，以自己墓地1只6星以上的植物族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
-- ②：这张卡在特殊召唤的回合不能攻击。
function c44451698.initial_effect(c)
	-- ①：这张卡用植物族怪兽的效果特殊召唤成功的场合，以自己墓地1只6星以上的植物族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44451698,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44451698)
	e1:SetCondition(c44451698.spcon)
	e1:SetTarget(c44451698.sptg)
	e1:SetOperation(c44451698.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在特殊召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c44451698.atklimit)
	c:RegisterEffect(e2)
end
-- 判断本次特殊召唤是否由植物族怪兽的效果造成
function c44451698.spcon(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_PLANT~=0
end
-- 筛选满足条件的墓地植物族怪兽（6星以上）
function c44451698.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标为满足条件的墓地植物族怪兽
function c44451698.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44451698.filter(chkc,e,tp) end
	-- 检查是否满足发动条件（场上是否有空位，墓地是否有符合条件的怪兽）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c44451698.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地植物族怪兽作为目标
	local g=Duel.SelectTarget(tp,c44451698.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 发动效果后，为对方玩家设置不能特殊召唤非植物族怪兽的效果，并特殊召唤目标怪兽
function c44451698.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 为对方玩家设置不能特殊召唤非植物族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(44451698,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44451698.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
	-- 检查场上是否还有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 限制非植物族怪兽的特殊召唤
function c44451698.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsRace(RACE_PLANT)
end
-- 设置此卡在特殊召唤回合不能攻击
function c44451698.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 设置此卡在特殊召唤回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
