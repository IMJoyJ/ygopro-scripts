--旗鼓堂々
-- 效果：
-- 选择自己墓地1张装备魔法卡和作为那个正确对象的场上1只怪兽才能发动。选择的装备魔法卡给选择的怪兽装备。这个效果装备的装备魔法卡在结束阶段时破坏。这张卡发动过的回合，自己不能把怪兽特殊召唤。「旗鼓堂堂」在1回合只能发动1张。
function c25067275.initial_effect(c)
	-- 此效果为发动效果，可自由连锁，只能发动一次，且不能在同回合再次发动。
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
-- 发动时，使自己不能特殊召唤怪兽。
function c25067275.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 使自己不能特殊召唤怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为表侧表示且装备魔法卡可装备给该怪兽。
function c25067275.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
-- 判断墓地是否存在装备魔法卡且该装备魔法卡可装备给场上的怪兽。
function c25067275.ecfilter(c)
	-- 判断墓地是否存在装备魔法卡且该装备魔法卡可装备给场上的怪兽。
	return c:IsType(TYPE_EQUIP) and Duel.IsExistingTarget(c25067275.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 设置效果的发动条件，需满足墓地有装备魔法卡且场上存在可装备对象，同时满足场地空位数量。
function c25067275.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 判断墓地是否存在装备魔法卡。
		if not Duel.IsExistingTarget(c25067275.ecfilter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			-- 若此卡在手牌则需场地上有2个空魔陷区，否则只需1个。
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 若此卡在手牌则需场地上有2个空魔陷区，否则只需1个。
		else return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end
	-- 提示玩家选择墓地的装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25067275,0))  --"请选择墓地的装备卡"
	-- 选择墓地的装备魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c25067275.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	-- 提示玩家选择要装备的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25067275,1))  --"请选择要装备的对象"
	-- 选择场上可装备的怪兽作为效果对象。
	Duel.SelectTarget(tp,c25067275.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
	-- 设置效果处理信息，表示将有1张卡从墓地离开。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ec,1,0,0)
end
-- 设置效果的处理流程，包括装备魔法卡与目标怪兽的装备操作。
function c25067275.operation(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取当前连锁中被选择的目标卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	-- 判断装备魔法卡是否表侧表示且有效，且目标怪兽是否有效，然后执行装备操作。
	if ec:IsFaceup() and ec:IsRelateToEffect(e) and Duel.Equip(tp,ec,tc) then
		-- 创建一个在结束阶段时破坏装备魔法卡的效果。
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
-- 装备魔法卡在结束阶段时被破坏。
function c25067275.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备魔法卡因效果而破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
