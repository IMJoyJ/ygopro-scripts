--旗鼓堂々
-- 效果：
-- 选择自己墓地1张装备魔法卡和作为那个正确对象的场上1只怪兽才能发动。选择的装备魔法卡给选择的怪兽装备。这个效果装备的装备魔法卡在结束阶段时破坏。这张卡发动过的回合，自己不能把怪兽特殊召唤。「旗鼓堂堂」在1回合只能发动1张。
function c25067275.initial_effect(c)
	-- 选择自己墓地1张装备魔法卡和作为那个正确对象的场上1只怪兽才能发动。选择的装备魔法卡给选择的怪兽装备。这个效果装备的装备魔法卡在结束阶段时破坏。这张卡发动过的回合，自己不能把怪兽特殊召唤。「旗鼓堂堂」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25067275+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c25067275.cost)
	e1:SetTarget(c25067275.target)
	e1:SetOperation(c25067275.operation)
	c:RegisterEffect(e1)
end
-- 作为发动时的誓约处理：给发动者附加直到结束阶段不能特殊召唤怪兽的效果。
function c25067275.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 选择自己墓地1张装备魔法卡和作为那个正确对象的场上1只怪兽才能发动。这张卡发动过的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将禁止特殊召唤的效果注册到当前玩家，使其在本回合内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：候选怪兽必须表侧表示，并且该装备卡可以装备给它。
function c25067275.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
-- 过滤函数：从墓地选择装备魔法卡，且场上存在可以成为其正确装备对象的表侧表示怪兽。
function c25067275.ecfilter(c)
	-- 该卡必须是装备魔法卡，并且场上至少存在1只满足条件的可装备对象。
	return c:IsType(TYPE_EQUIP) and Duel.IsExistingTarget(c25067275.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 发动时进行目标选择：检查合法性，然后选择墓地1张装备魔法卡和场上1只符合条件的怪兽作为对象，并登记操作信息。
function c25067275.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 若不存在满足条件的装备魔法卡（墓地没有装备卡，或场上没有可装备对象），则不能发动。
		if not Duel.IsExistingTarget(c25067275.ecfilter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			-- 若此卡从手卡发动，需要至少2个魔陷区空格：1个用于发动此卡，1个用于放置装备卡。
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 否则只需至少1个魔陷区空格来放置装备卡。
		else return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end
	-- 显示选择提示，要求玩家从墓地选择装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25067275,0))  --"请选择墓地的装备卡"
	-- 从自己墓地选择1张满足条件的装备魔法卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c25067275.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	-- 显示选择提示，要求玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25067275,1))  --"请选择要装备的对象"
	-- 选择场上1只表侧表示且能被该装备卡装备的怪兽作为装备对象。
	Duel.SelectTarget(tp,c25067275.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
	-- 登记操作信息：该装备卡将离开墓地，以便应对相关卡片的干扰/时点。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ec,1,0,0)
end
-- 效果处理：取出装备卡和对象怪兽，若状态合法则进行装备；成功装备后为装备卡注册结束阶段自毁效果。
function c25067275.operation(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取当前连锁的目标卡组，取得之前选择的装备卡与对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	-- 确认装备卡仍表侧且与本效果关联，并尝试将其装备给对象怪兽；装备成功则继续设置破坏效果。
	if ec:IsFaceup() and ec:IsRelateToEffect(e) and Duel.Equip(tp,ec,tc) then
		-- 这个效果装备的装备魔法卡在结束阶段时破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(c25067275.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
-- 结束阶段触发处理：破坏以此效果装备的该装备魔法卡。
function c25067275.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将该装备魔法卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
