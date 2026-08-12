--イビリチュア・メロウガイスト
-- 效果：
-- 4星怪兽×2
-- 这张卡战斗破坏对方怪兽的场合，那次伤害计算后可以把这张卡1个超量素材取除，破坏的那只怪兽不送去墓地回到持有者卡组。
function c76372778.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏对方怪兽的场合，那次伤害计算后可以把这张卡1个超量素材取除，破坏的那只怪兽不送去墓地回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76372778,0))  --"战斗破坏的怪兽返回卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c76372778.condition)
	e1:SetCost(c76372778.cost)
	e1:SetOperation(c76372778.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身未被战斗破坏，且战斗破坏的对方怪兽不是衍生物，且该怪兽离场时没有其他改变去向的效果，且其目的地不是卡组
function c76372778.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not bc:IsType(TYPE_TOKEN)
		and bc:GetLeaveFieldDest()==0 and bc:GetDestination()~=LOCATION_DECK
end
-- 检查并取除这张卡的1个超量素材作为发动的代价
function c76372778.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：给被战斗破坏的怪兽注册一个离场重定向效果，使其在因战斗破坏送去墓地时改为回到持有者卡组并洗牌
function c76372778.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 破坏的那只怪兽不送去墓地回到持有者卡组
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetCondition(c76372778.recon)
		e1:SetValue(LOCATION_DECKSHF)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e1)
	end
end
-- 重定向适用条件：该怪兽因战斗破坏且目的地为墓地
function c76372778.recon(e)
	local c=e:GetHandler()
	return c:GetDestination()==LOCATION_GRAVE and c:IsReason(REASON_BATTLE)
end
