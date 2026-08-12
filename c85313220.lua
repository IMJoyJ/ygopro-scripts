--漆黒の魔王 LV4
-- 效果：
-- 这张卡战斗破坏的对方怪兽的效果无效化。这张卡战斗破坏怪兽的下次的自己回合的准备阶段时，可以把这张卡送去墓地从手卡·卡组特殊召唤1只「漆黑之魔王 LV6」。
function c85313220.initial_effect(c)
	-- 这张卡战斗破坏的对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c85313220.disop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽的下次的自己回合的准备阶段时，可以把这张卡送去墓地从手卡·卡组特殊召唤1只「漆黑之魔王 LV6」。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c85313220.btop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏怪兽的下次的自己回合的准备阶段时，可以把这张卡送去墓地从手卡·卡组特殊召唤1只「漆黑之魔王 LV6」。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85313220,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c85313220.spcon)
	e3:SetCost(c85313220.spcost)
	e3:SetTarget(c85313220.sptg)
	e3:SetOperation(c85313220.spop)
	c:RegisterEffect(e3)
end
c85313220.lvup={12817939}
-- 在伤害计算后，若自身未被战斗破坏且对方怪兽已被战斗破坏，则将该对方怪兽的效果无效化。
function c85313220.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击目标。
	local d=Duel.GetAttackTarget()
	-- 如果攻击目标是自身，则将战斗对手设定为攻击者。
	if d==c then d=Duel.GetAttacker() end
	if d and d:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 这张卡战斗破坏的对方怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		d:RegisterEffect(e1)
	end
end
-- 在自身战斗破坏怪兽时注册一个Flag，该Flag在2次自己回合结束时重置，用于记录战斗破坏过怪兽的状态。
function c85313220.btop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(85313220,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
end
-- 检查是否满足特殊召唤「漆黑之魔王 LV6」的条件（当前为自己的准备阶段，且自身带有战斗破坏过怪兽的Flag）。
function c85313220.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己，且自身是否带有战斗破坏过怪兽的Flag。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(85313220)~=0
end
-- 检查并执行将自身送去墓地作为发动的代价。
function c85313220.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手牌或卡组中可以无视召唤条件特殊召唤的「漆黑之魔王 LV6」。
function c85313220.spfilter(c,e,tp)
	return c:IsCode(12817939) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 检查怪兽区域是否有空位，以及手牌或卡组中是否存在满足条件的「漆黑之魔王 LV6」，并设置特殊召唤的操作信息。
function c85313220.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用位置（由于作为代价的自身会送去墓地空出格子，因此可用位置数大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌或卡组中是否存在至少1张满足特殊召唤条件的「漆黑之魔王 LV6」。
		and Duel.IsExistingMatchingCard(c85313220.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手牌或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理：从手牌或卡组选择1只「漆黑之魔王 LV6」特殊召唤，并完成正规召唤程序。
function c85313220.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若没有则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组中选择1只满足条件的「漆黑之魔王 LV6」。
	local g=Duel.SelectMatchingCard(tp,c85313220.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
