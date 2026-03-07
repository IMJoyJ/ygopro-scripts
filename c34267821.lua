--アーティファクト－ロンギヌス
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，把手卡·场上的这张卡解放才能发动。这个回合，双方不能把卡除外。
function c34267821.initial_effect(c)
	-- 效果原文：①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 效果原文：②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34267821,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c34267821.spcon)
	e2:SetTarget(c34267821.sptg)
	e2:SetOperation(c34267821.spop)
	c:RegisterEffect(e2)
	-- 效果原文：③：对方回合，把手卡·场上的这张卡解放才能发动。这个回合，双方不能把卡除外。
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
-- 规则层面：判断是否满足特殊召唤条件，即该卡从魔陷区背面表示被破坏送入墓地且为对方回合。
function c34267821.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 规则层面：判断是否为对方回合。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 规则层面：设置特殊召唤的操作信息。
function c34267821.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作。
function c34267821.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面：将该卡以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面：判断是否为对方回合。
function c34267821.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 规则层面：设置解放作为发动代价。
function c34267821.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 规则层面：将该卡解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 规则层面：判断是否已发动过此效果。
function c34267821.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断是否已发动过此效果。
	if chk==0 then return Duel.GetFlagEffect(tp,34267821)==0 end
end
-- 规则层面：注册双方不能除外的效果。
function c34267821.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：双方不能把卡除外
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面：注册不能除外的效果。
	Duel.RegisterEffect(e1,tp)
	-- 规则层面：注册标识效果，防止再次发动此效果。
	Duel.RegisterFlagEffect(tp,34267821,RESET_PHASE+PHASE_END,0,1)
end
