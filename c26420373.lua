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
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
	-- 「疾行机人 超车滑翔骑手」的①的方法的特殊召唤1回合只能有1次。
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
-- 定义用于判断是否可以作为灵摆效果cost的「疾行机人」调整怪兽的过滤函数
function c26420373.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost()
end
-- 灵摆效果的cost处理函数，检查手牌和场上的「疾行机人」调整怪兽并将其送去墓地
function c26420373.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌和场上的「疾行机人」调整怪兽是否存在以满足cost条件
	if chk==0 then return Duel.IsExistingMatchingCard(c26420373.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「疾行机人」调整怪兽
	local g=Duel.SelectMatchingCard(tp,c26420373.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 灵摆效果的处理函数，根据选择决定刻度变化方向并应用效果
function c26420373.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local sel=0
	if c:GetLeftScale()==1 then
		-- 当灵摆刻度为1时，仅提供刻度上升选项
		sel=Duel.SelectOption(tp,aux.Stringid(26420373,1))  --"刻度上升"
	else
		-- 当灵摆刻度大于1时，提供刻度上升或下降选项
		sel=Duel.SelectOption(tp,aux.Stringid(26420373,1),aux.Stringid(26420373,2))  --"刻度上升/刻度下降"
	end
	if sel==1 then
		ct=-math.min(ct,c:GetLeftScale()-1)
	end
	-- 创建一个用于修改灵摆刻度的永续效果，修改左侧刻度
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
-- 特殊召唤条件函数，判断是否满足手牌特殊召唤的条件
function c26420373.hspcon(e,c)
	if c==nil then return true end
	-- 检查己方场上是否没有怪兽存在
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,LOCATION_MZONE)==0
		-- 检查己方场上是否有足够的召唤区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 上级召唤成功时触发的效果条件函数
function c26420373.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 用于判断墓地中的「疾行机人」怪兽是否满足特殊召唤条件的过滤函数
function c26420373.spfilter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标选择函数，检查墓地中的「疾行机人」怪兽是否满足特殊召唤条件
function c26420373.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26420373.spfilter(chkc,e,tp) end
	-- 检查墓地是否存在满足条件的「疾行机人」怪兽
	if chk==0 then return Duel.IsExistingTarget(c26420373.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查己方场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地中的「疾行机人」怪兽作为目标
	local g=Duel.SelectTarget(tp,c26420373.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，确定特殊召唤的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理函数，将目标怪兽特殊召唤到场上
function c26420373.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击限制效果的判断函数，防止对方选择其他「疾行机人」怪兽作为攻击对象
function c26420373.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x2016)
end
