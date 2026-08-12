--Re－BUSTER
-- 效果：
-- 把自己墓地存在的1张「爆裂模式」从游戏中除外发动。自己场上存在的怪兽全部破坏，自己墓地存在的1只名字带有「/爆裂体」的怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的效果无效化，也不能解放，从场上离开的场合从游戏中除外。
function c56252810.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果中记有「爆裂模式」（卡号80280737）。
	aux.AddCodeList(c,80280737)
	-- 把自己墓地存在的1张「爆裂模式」从游戏中除外发动。自己场上存在的怪兽全部破坏，自己墓地存在的1只名字带有「/爆裂体」的怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的效果无效化，也不能解放，从场上离开的场合从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c56252810.cost)
	e1:SetTarget(c56252810.target)
	e1:SetOperation(c56252810.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地存在的「爆裂模式」且可以作为除外代价。
function c56252810.cfilter(c)
	return c:IsCode(80280737) and c:IsAbleToRemoveAsCost()
end
-- 发动代价（Cost）处理：将自己墓地1张「爆裂模式」除外。
function c56252810.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张满足除外代价条件的「爆裂模式」。
	if chk==0 then return Duel.IsExistingMatchingCard(c56252810.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地存在的1张「爆裂模式」。
	local g=Duel.SelectMatchingCard(tp,c56252810.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地存在的、可以无视召唤条件特殊召唤的名字带有「/爆裂体」的怪兽。
function c56252810.filter(c,e,tp)
	return c:IsSetCard(0x104f) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果的目标（Target）处理：检查发动条件并选择墓地的「/爆裂体」怪兽作为对象。
function c56252810.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56252810.filter(chkc,e,tp) end
	-- 检查自己场上是否存在至少1只怪兽（用于破坏）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己墓地是否存在至少1只可以特殊召唤的「/爆裂体」怪兽。
		and Duel.IsExistingTarget(c56252810.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取自己场上存在的所有怪兽。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地存在的1只「/爆裂体」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c56252810.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含破坏自己场上所有怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
	-- 设置连锁信息：包含特殊召唤1只墓地怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的执行（Operation）处理：破坏自己场上的怪兽，并特殊召唤墓地的「/爆裂体」怪兽，同时施加限制效果。
function c56252810.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上存在的所有怪兽。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 破坏自己场上存在的所有怪兽，若未能全部破坏则效果处理终止。
	if Duel.Destroy(dg,REASON_EFFECT)~=dg:GetCount() then return end
	-- 检查自己场上是否有可用的怪兽区域，若无则无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的「/爆裂体」怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽无视召唤条件以表侧表示特殊召唤，若特殊召唤失败则终止后续处理。
		if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)==0 then return end
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 也不能解放
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UNRELEASABLE_SUM)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		tc:RegisterEffect(e3,true)
		-- 也不能解放
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4:SetValue(1)
		tc:RegisterEffect(e4,true)
		-- 从场上离开的场合从游戏中除外。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e5:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e5:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e5,true)
	end
end
