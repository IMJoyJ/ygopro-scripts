--ダーク・ネフティス
-- 效果：
-- 自己的主要阶段时自己墓地的暗属性怪兽是3只以上的场合，可以通过把那之内2只从游戏中除外，这张卡从手卡送去墓地。下次的自己的准备阶段时，这个效果送去墓地的这张卡从墓地特殊召唤。此外，这张卡特殊召唤成功时，选择场上1张魔法·陷阱卡破坏。
function c38107923.initial_effect(c)
	-- 自己的主要阶段时自己墓地的暗属性怪兽是3只以上的场合，可以通过把那之内2只从游戏中除外，这张卡从手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38107923,0))  --"送去墓地"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38107923.tgcon)
	e1:SetCost(c38107923.tgcost)
	e1:SetTarget(c38107923.tgtg)
	e1:SetOperation(c38107923.tgop)
	c:RegisterEffect(e1)
	-- 下次的自己的准备阶段时，这个效果送去墓地的这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38107923,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c38107923.spcon)
	e2:SetTarget(c38107923.sptg)
	e2:SetOperation(c38107923.spop)
	c:RegisterEffect(e2)
	-- 此外，这张卡特殊召唤成功时，选择场上1张魔法·陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38107923,2))  --"魔法·陷阱卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c38107923.destg)
	e3:SetOperation(c38107923.desop)
	c:RegisterEffect(e3)
end
-- 判定效果发动条件：检查自己墓地是否存在至少3只暗属性怪兽。
function c38107923.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地中暗属性怪兽的数量是否达到3只以上。
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,3,nil,ATTRIBUTE_DARK)
end
-- 定义代价过滤条件：怪兽必须是暗属性且可以作为代价移除。
function c38107923.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：从自己墓地选择2只暗属性怪兽除外作为发动代价。
function c38107923.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地中是否存在2只符合条件的暗属性怪兽可以除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c38107923.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只暗属性怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c38107923.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2只怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设定效果目标：确认这张卡可以送去墓地，并设置相关操作信息。
function c38107923.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave() end
	-- 设置操作信息：本次效果会将这张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡从手卡送去墓地，并为其设置用于下次准备阶段特殊召唤的标记。
function c38107923.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从手卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		c:RegisterFlagEffect(38107923,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判定特殊召唤效果的发动条件：此卡是由自身效果送去墓地，且当前是下次自己的准备阶段。
function c38107923.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤条件：此卡不是本回合送去墓地，当前为准备阶段且是自己回合，并持有标记。
	return c:GetTurnID()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(38107923)>0
end
-- 特殊召唤效果发动时设置：允许发动，设置特殊召唤操作信息并清除标记。
function c38107923.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置操作信息：本次效果会特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(38107923)
end
-- 特殊召唤效果处理：若此卡仍在墓地且与效果相关，则将其特殊召唤。
function c38107923.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义破坏对象过滤条件：卡必须为魔法·陷阱卡。
function c38107923.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标处理：选择场上1张魔法·陷阱卡为对象，并设置破坏操作信息。
function c38107923.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c38107923.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c38107923.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：确定要破坏的对象及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理：若所选对象仍与效果相关，则将其破坏。
function c38107923.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
