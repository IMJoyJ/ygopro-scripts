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
	-- ②：这张卡的①的效果特殊召唤的场合发动。场上的其他怪兽全部破坏。
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
	-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把「炎王神兽 大鹏不死鸟」以外的1只「炎王」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23015896,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c23015896.descon)
	e3:SetTarget(c23015896.destg)
	e3:SetOperation(c23015896.desop)
	c:RegisterEffect(e3)
	-- 效果作用
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
-- 检索满足条件的卡片组
function c23015896.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 将目标怪兽特殊召唤
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 效果作用
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(23015896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(23015896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
-- 效果原文内容
function c23015896.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(23015896)>0
end
-- 效果作用
function c23015896.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(23015896)
end
-- 效果作用
function c23015896.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果原文内容
function c23015896.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果作用
function c23015896.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用
function c23015896.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 破坏满足条件的卡片组
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果原文内容
function c23015896.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数
function c23015896.spfilter(c,e,tp)
	return c:IsSetCard(0x81) and not c:IsCode(23015896) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用
function c23015896.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤条件
		and Duel.IsExistingMatchingCard(c23015896.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用
function c23015896.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡片组
	local g=Duel.SelectMatchingCard(tp,c23015896.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
