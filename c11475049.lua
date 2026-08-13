--アーティファクト－アキレウス
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。对方回合中这张卡特殊召唤成功的场合，这个回合对方不能把自己场上的名字带有「古遗物」的怪兽作为攻击对象。
function c11475049.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11475049,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c11475049.spcon)
	e2:SetTarget(c11475049.sptg)
	e2:SetOperation(c11475049.spop)
	c:RegisterEffect(e2)
	-- 对方回合中这张卡特殊召唤成功的场合，这个回合对方不能把自己场上的名字带有「古遗物」的怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11475049,1))  --"攻击限制"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c11475049.atcon)
	e3:SetOperation(c11475049.atop)
	c:RegisterEffect(e3)
end
-- 判定诱发条件：这张卡在对方回合，从魔法与陷阱区域里侧表示被破坏送去墓地，且破坏前的控制者是这张卡的效果发动方。
function c11475049.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 进一步确认该卡片是因为被破坏而送去墓地，并且当前回合不是效果发动方的回合（即对方回合）。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 作为特殊召唤效果的发动目标判定：不取对象，只要上述条件成立即可发动；同时登记本次效果将进行特殊召唤。
function c11475049.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣告效果处理时会把这张卡自身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联（未被除外/同名卡取代等），则将其以表侧表示特殊召唤。
function c11475049.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其控制者tp的场上，召唤手续不检查召唤条件和苏生限制。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击限制效果的诱发条件：只有在对方回合中这张卡特殊召唤成功时才满足。
function c11475049.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是这张卡的控制者（即对方回合），则条件成立。
	return Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤成功后的处理：为tp方注册一个直到结束阶段有效的场地效果，限制对方不能选择我方场上的「古遗物」怪兽作为攻击对象。
function c11475049.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合中这张卡特殊召唤成功的场合，这个回合对方不能把自己场上的名字带有「古遗物」的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c11475049.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击限制效果注册到游戏中，由tp作为效果控制者，效果持续至结束阶段时重置。
	Duel.RegisterEffect(e1,tp)
end
-- 判断攻击对象是否是我方场上表侧表示且卡名属于「古遗物」的怪兽；若是，则对方不能将其选为攻击对象。
function c11475049.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x97)
end
