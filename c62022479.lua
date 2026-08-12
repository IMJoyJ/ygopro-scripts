--烙印の絆
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·墓地·除外状态的1只「阿不思的落胤」特殊召唤。
-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
function c62022479.initial_effect(c)
	-- 注册卡片脚本中提及了「阿不思的落胤」的卡片密码。
	aux.AddCodeList(c,68468459)
	-- ①：自己的手卡·墓地·除外状态的1只「阿不思的落胤」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62022479,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62022479)
	e1:SetTarget(c62022479.target)
	e1:SetOperation(c62022479.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c62022479.regcon)
	e2:SetOperation(c62022479.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62022479,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,62022480)
	e3:SetCondition(c62022479.setcon)
	e3:SetTarget(c62022479.settg)
	e3:SetOperation(c62022479.setop)
	c:RegisterEffect(e3)
end
-- 过滤手卡、墓地、除外状态的「阿不思的落胤」且可以特殊召唤的卡片。
function c62022479.spfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE)) and c:IsCode(68468459) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数。
function c62022479.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、墓地、除外状态是否存在至少1只满足特殊召唤条件的「阿不思的落胤」。
		and Duel.IsExistingMatchingCard(c62022479.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从手卡、墓地或除外状态特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果①的处理函数，执行特殊召唤。
function c62022479.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域空格，若无可用空格则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡、墓地、除外状态选择1只满足条件的「阿不思的落胤」（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c62022479.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否作为「阿不思的落胤」发动效果的Cost（代价）被送去墓地。
function c62022479.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该连锁的效果对应的卡片密码。
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated() and (code1==68468459 or code2==68468459)
end
-- 给这张卡注册一个在回合结束前有效的标记（Flag），用于记录其满足盖放条件。
function c62022479.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(62022479,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查这张卡是否带有满足盖放条件的标记。
function c62022479.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(62022479)>0
end
-- 效果②的发动准备与合法性检测函数。
function c62022479.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置连锁处理的操作信息为：使墓地的这张卡离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数，执行盖放。
function c62022479.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上盖放。
		Duel.SSet(tp,c)
	end
end
