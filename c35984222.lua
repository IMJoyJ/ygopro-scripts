--超魔神イド
-- 效果：
-- 这张卡被卡的效果破坏送去墓地的场合，下个回合的准备阶段时这张卡从墓地特殊召唤，这张卡以外的自己场上存在的怪兽全部破坏。只要这张卡在自己场上表侧表示存在，自己不能把怪兽通常召唤·反转召唤·特殊召唤。「超魔神 本我」在自己场上只能有1张表侧表示存在。
function c35984222.initial_effect(c)
	c:SetUniqueOnField(1,0,35984222)
	-- 这张卡被卡的效果破坏送去墓地的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c35984222.spr)
	c:RegisterEffect(e1)
	-- 下个回合的准备阶段时这张卡从墓地特殊召唤，这张卡以外的自己场上存在的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35984222,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c35984222.spcon)
	e2:SetTarget(c35984222.sptg)
	e2:SetOperation(c35984222.spop)
	c:RegisterEffect(e2)
	-- 自己不能把怪兽通常召唤·反转召唤·特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e6)
end
-- 这张卡被卡的效果破坏送去墓地时，若破坏原因包含效果破坏且原位置不是魔陷区，则给它记录一个标记，该标记持续到下次结束阶段，用于判断是否满足下个准备阶段特殊召唤的条件。
function c35984222.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 or c:IsPreviousLocation(LOCATION_SZONE) then return end
	c:RegisterFlagEffect(35984222,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 特殊召唤的诱发条件：该卡被效果破坏送去墓地后，在下个回合的准备阶段且带有之前记录的标记时，允许发动效果。
function c35984222.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定该卡被送去墓地的回合不是当前回合（即已经经过至少一个回合），并且该卡带有破坏记录标记。
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(35984222)>0
end
-- 效果发动时的目标处理：无对象选择，设定操作信息，包括要特殊召唤这张卡以及破坏自己场上除这张卡以外的所有怪兽。
function c35984222.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上除这张卡以外的所有怪兽（此时这张卡在墓地，实际就是自己场上所有怪兽）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 设定操作信息：将破坏集合g中的所有怪兽，数量为g的数量，供连锁处理时检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设定操作信息：将特殊召唤这张卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果相关，先以表侧表示特殊召唤；特殊召唤成功后再破坏自己场上除这张卡以外的所有怪兽。
function c35984222.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联，并尝试以表侧表示特殊召唤，且特殊召唤成功（返回值不为0）才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤成功后，获取自己场上除这张卡以外的所有怪兽。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,c)
		-- 以效果破坏原因将这些怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
