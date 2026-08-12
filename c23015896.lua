--炎王神獣 ガルドニクス
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合，下次的准备阶段发动。这张卡从墓地特殊召唤。
-- ②：这张卡的①的效果特殊召唤的场合发动。场上的其他怪兽全部破坏。
-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把「炎王神兽 大鹏不死鸟」以外的1只「炎王」怪兽特殊召唤。
function c23015896.initial_effect(c)
	-- ①：这张卡被效果破坏送去墓地的场合，下次的准备阶段发动。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c23015896.spreg)
	c:RegisterEffect(e1)
	-- ①：这张卡被效果破坏送去墓地的场合，下次的准备阶段发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23015896,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c23015896.spcon)
	e2:SetTarget(c23015896.sptg)
	e2:SetOperation(c23015896.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果特殊召唤的场合发动。场上的其他怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23015896,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c23015896.descon)
	e3:SetTarget(c23015896.destg)
	e3:SetOperation(c23015896.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把「炎王神兽 大鹏不死鸟」以外的1只「炎王」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23015896,2))  --"卡组特召"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCondition(c23015896.spcon2)
	e4:SetTarget(c23015896.sptg2)
	e4:SetOperation(c23015896.spop2)
	c:RegisterEffect(e4)
end
-- 注册效果①的触发标记，判断是否为效果破坏送墓，并根据当前阶段设置延迟发动的回合数标记。
function c23015896.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断当前是否为准备阶段，用于处理在同一准备阶段被破坏时的时点计数逻辑。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数，用于后续判断是否为“下次”的准备阶段。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(23015896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(23015896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
-- 效果①的发动条件，检查是否满足“下次准备阶段”以及卡片是否仍持有触发标记。
function c23015896.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断回合数是否不同（确保是下次准备阶段）且标记存在（确保是效果破坏送墓）。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(23015896)>0
end
-- 效果①的目标函数，设置特殊召唤的操作信息并重置标记。
function c23015896.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 宣告效果分类为特殊召唤，目标为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(23015896)
end
-- 效果①的操作函数，执行特殊召唤操作。
function c23015896.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地特殊召唤，并标记召唤来源为效果①（SUMMON_VALUE_SELF）。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件，判断是否为效果①的特殊召唤成功。
function c23015896.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果②的目标函数，选取场上除这张卡以外的所有怪兽作为破坏对象。
function c23015896.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除这张卡以外的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 宣告效果分类为破坏，目标为选取的怪兽组。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的操作函数，执行破坏场上其他怪兽的处理。
function c23015896.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次过滤场上怪兽，排除自身（使用ExceptThisCard确保逻辑严谨）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 破坏选中的怪兽组。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果③的发动条件，判断是否为被战斗破坏送去墓地。
function c23015896.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果③的过滤函数，检查是否为「炎王」怪兽且非本卡名且可特殊召唤。
function c23015896.spfilter(c,e,tp)
	return c:IsSetCard(0x81) and not c:IsCode(23015896) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的目标函数，检查是否有空位并设置特殊召唤的操作信息。
function c23015896.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「炎王」怪兽。
		and Duel.IsExistingMatchingCard(c23015896.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 宣告效果分类为特殊召唤，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的操作函数，从卡组选择怪兽并特殊召唤。
function c23015896.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查怪兽区域是否可用，若无可用的则效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c23015896.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
