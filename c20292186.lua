--アーティファクト－デスサイズ
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，这张卡特殊召唤成功的场合发动。这个回合，对方不能从额外卡组把怪兽特殊召唤。
function c20292186.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20292186,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c20292186.spcon)
	e2:SetTarget(c20292186.sptg)
	e2:SetOperation(c20292186.spop)
	c:RegisterEffect(e2)
	-- ③：对方回合，这张卡特殊召唤成功的场合发动。这个回合，对方不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20292186,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c20292186.dcon)
	e3:SetOperation(c20292186.dop)
	c:RegisterEffect(e3)
end
-- 判断②效果的发动条件：这张卡此前位于魔法与陷阱区域且为里侧表示，之前控制者为自己，且因破坏被送去墓地，并且当前为对方回合。
function c20292186.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 继续判断条件：此卡被破坏，且当前回合玩家不是此卡原控制者（即对方回合）。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- ②效果发动时的目标处理：无取对象，直接允许发动，并登记特殊召唤的操作信息。
function c20292186.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果处理中会将这张卡自身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理时：若这张卡仍与效果关联，则将其特殊召唤。
function c20292186.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：当前为对方回合。
function c20292186.dcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者（即对方回合），满足③效果的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ③效果处理时：为对方玩家施加一个直到结束阶段的限制效果，使其不能从额外卡组特殊召唤怪兽。
function c20292186.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c20292186.sumlimit)
	-- 将该限制效果注册到决斗中，影响对方玩家，直到结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定条件：只有从额外卡组进行的特殊召唤会被禁止。
function c20292186.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
