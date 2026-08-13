--アーティファクト－ロンギヌス
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，把手卡·场上的这张卡解放才能发动。这个回合，双方不能把卡除外。
function c34267821.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34267821,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c34267821.spcon)
	e2:SetTarget(c34267821.sptg)
	e2:SetOperation(c34267821.spop)
	c:RegisterEffect(e2)
	-- 对方回合，把手卡·场上的这张卡解放才能发动。这个回合，双方不能把卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34267821,1))  --"双方不能把卡除外"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCondition(c34267821.rmcon)
	e3:SetCost(c34267821.rmcost)
	e3:SetTarget(c34267821.rmtg)
	e3:SetOperation(c34267821.rmop)
	c:RegisterEffect(e3)
end
-- 判断诱发条件：这张卡此前位于魔法与陷阱区域且为里侧盖放、控制者为这张卡的原本控制者（tp）、因破坏被送去墓地，且当前为对方回合。
function c34267821.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断该卡必须是被破坏送去墓地，且当前回合玩家不是这张卡的控制者（即对方回合）。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 发动时无选择对象，只要满足条件即可发动；同时将特殊召唤这张卡的信息登记到连锁，供后续处理或相关卡检测。
function c34267821.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息登记为：特殊召唤这张卡1张，对象卡为e:GetHandler()，不指定玩家和位置。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与处理中的效果关联（未被无效或离场导致关系重置），则将其特殊召唤。
function c34267821.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其操控者tp的场上，sumtype为0（通常召唤手续），同时检查召唤条件和苏生限制。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果只能在对方回合发动，此函数判断当前回合玩家不是这张卡的控制者。
function c34267821.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前回合玩家不是tp（即当前是对方回合），满足③的发动时机。
	return Duel.GetTurnPlayer()~=tp
end
-- ③以解放手牌或场上的这张卡为发动代价；chk==0时检查这张卡是否可解放，可则通过；实际发动时执行解放。
function c34267821.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 作为代价将这张卡解放（送入墓地）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 发动时无对象，但需要确认本回合尚未使用过③（通过flag标记），避免重复发动。若已有flag则不能发动。
function c34267821.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否有34267821标记，标记为0时才可发动，确保该效果在同一回合只能发动一次。
	if chk==0 then return Duel.GetFlagEffect(tp,34267821)==0 end
end
-- 效果处理时，为双方玩家附加“不能把卡除外”的永续效果，并给自己打上已发动标记；这些效果均在结束阶段重置。
function c34267821.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，双方不能把卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚刚生成的“不能把卡除外”效果注册到玩家tp侧，影响双方（SetTargetRange(1,1)），持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 给tp注册一个结束阶段重置的标记，表示本回合已发动过③，防止重复发动。
	Duel.RegisterFlagEffect(tp,34267821,RESET_PHASE+PHASE_END,0,1)
end
