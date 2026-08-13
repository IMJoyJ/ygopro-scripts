--SRパッシングライダー
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，从手卡以及自己场上的表侧表示怪兽之中把1只「疾行机人」调整送去墓地才能发动。直到回合结束时，这张卡的灵摆刻度上升或者下降送去墓地的那只怪兽的原本等级数值（最少到1）。
-- 【怪兽效果】
-- 「疾行机人 超车滑翔骑手」的①的方法的特殊召唤1回合只能有1次。
-- ①：双方场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡上级召唤成功时，以自己墓地1只4星以下的「疾行机人」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：只要这张卡在怪兽区域存在，对方不能选择其他的「疾行机人」怪兽作为攻击对象。
function c26420373.initial_effect(c)
	-- 将这张卡注册为灵摆怪兽，使其获得灵摆召唤与灵摆卡发动相关属性。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，从手卡以及自己场上的表侧表示怪兽之中把1只「疾行机人」调整送去墓地才能发动。直到回合结束时，这张卡的灵摆刻度上升或者下降送去墓地的那只怪兽的原本等级数值（最少到1）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26420373,0))  --"刻度变更"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26420373.sccost)
	e1:SetOperation(c26420373.scop)
	c:RegisterEffect(e1)
	-- 「疾行机人 超车滑翔骑手」的①的方法的特殊召唤1回合只能有1次。①：双方场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,26420373+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c26420373.hspcon)
	c:RegisterEffect(e2)
	-- ②：这张卡上级召唤成功时，以自己墓地1只4星以下的「疾行机人」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26420373,3))  --"墓地「疾行机人」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c26420373.spcon)
	e3:SetTarget(c26420373.sptg)
	e3:SetOperation(c26420373.spop)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，对方不能选择其他的「疾行机人」怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c26420373.atlimit)
	c:RegisterEffect(e4)
end
-- costfilter：筛选可作为代价的卡——是「疾行机人」字段的调整怪兽，且可以送去墓地作为代价。
function c26420373.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost()
end
-- sccost：检查并支付发动代价——从手卡及自己场上的表侧表示怪兽中选1只「疾行机人」调整怪兽送去墓地，并将其原本等级值记录在Label中，供效果处理时使用。
function c26420373.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查是否存在至少1只满足costfilter的卡，也就是确认是否有合法代价可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c26420373.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡及自己场上的表侧表示怪兽中选择1张满足costfilter的「疾行机人」调整怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c26420373.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将所选卡以代价（REASON_COST）形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 操作处理：根据玩家选择决定灵摆刻度上升或下降该卡的左右刻度；若选择下降，则将原本等级取负并限制最低刻度为1；随后注册左右灵摆刻度变更效果，持续到回合结束。
function c26420373.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local sel=0
	if c:GetLeftScale()==1 then
		-- 当左刻度为1时，无法再选择下降，因此只提供“刻度上升”选项。
		sel=Duel.SelectOption(tp,aux.Stringid(26420373,1))  --"刻度上升"
	else
		-- 当左刻度大于1时，让玩家选择“刻度上升”还是“刻度下降”。
		sel=Duel.SelectOption(tp,aux.Stringid(26420373,1),aux.Stringid(26420373,2))  --"刻度上升/刻度下降"
	end
	if sel==1 then
		ct=-math.min(ct,c:GetLeftScale()-1)
	end
	-- 直到回合结束时，这张卡的灵摆刻度上升或者下降送去墓地的那只怪兽的原本等级数值（最少到1）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(ct)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end
-- hspcon：特殊召唤规则条件——双方场上没有怪兽存在，且自己场上有可用的怪兽区域。
function c26420373.hspcon(e,c)
	if c==nil then return true end
	-- 判断双方场上（主要怪兽区域）的怪兽数合计为0，即双方场上没有怪兽存在。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,LOCATION_MZONE)==0
		-- 判断自己场上是否有空余的怪兽区域可供特殊召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- spcon：作为诱发效果的发动条件——这张卡上级召唤成功时。
function c26420373.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- spfilter：筛选可特殊召唤的对象——自己墓地中4星以下的「疾行机人」怪兽，且满足特殊召唤条件（苏生限制等）。
function c26420373.spfilter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg：发动时选择对象——以自己墓地1只4星以下的「疾行机人」怪兽为对象，同时确认场上是否有空位；若为取对象合法性核对则返回该对象是否满足条件。
function c26420373.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26420373.spfilter(chkc,e,tp) end
	-- chk==0时检查墓地是否存在1只满足spfilter的怪兽，即是否有可特殊召唤的对象。
	if chk==0 then return Duel.IsExistingTarget(c26420373.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时检查自己的主要怪兽区域是否有空位可放置特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c26420373.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将进行1次特殊召唤，供相关效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop：效果处理——取得对象卡，若对象仍与效果关联则将其特殊召唤到场上。
function c26420373.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中该效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧攻击表示特殊召唤到自己的场上（按常规检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- atlimit：判定哪些怪兽不能被对方选择为攻击对象——除这张卡自身以外的、表侧表示的「疾行机人」怪兽。
function c26420373.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x2016)
end
