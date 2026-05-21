--月天気アルシエル
-- 效果：
-- 「天气」怪兽3只
-- ①：这张卡连接召唤成功的场合才能发动。选除外的1只自己的「天气」怪兽特殊召唤。
-- ②：这张卡所连接区的「天气」效果怪兽得到以下效果。
-- ●自己·对方回合，把这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽直到下个回合的准备阶段除外。
-- ③：连接召唤的这张卡被破坏的场合才能发动。从额外卡组把1只「虹天气 彩虹」特殊召唤。
function c95515518.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：需要3只「天气」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x109),3,3)
	-- ①：这张卡连接召唤成功的场合才能发动。选除外的1只自己的「天气」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95515518,0))  --"除外的「天气」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c95515518.spcon)
	e1:SetTarget(c95515518.sptg)
	e1:SetOperation(c95515518.spop)
	c:RegisterEffect(e1)
	-- ●自己·对方回合，把这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽直到下个回合的准备阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95515518,1))  --"对方怪兽除外（月天气 彩虹）"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c95515518.rmcost)
	e2:SetTarget(c95515518.rmtg)
	e2:SetOperation(c95515518.rmop)
	-- ②：这张卡所连接区的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c95515518.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：连接召唤的这张卡被破坏的场合才能发动。从额外卡组把1只「虹天气 彩虹」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95515518,2))  --"从额外卡组特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c95515518.spcon2)
	e4:SetTarget(c95515518.sptg2)
	e4:SetOperation(c95515518.spop2)
	c:RegisterEffect(e4)
end
-- 判定效果①的发动条件：这张卡是连接召唤成功
function c95515518.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤条件：除外的、表侧表示的、可以特殊召唤的「天气」怪兽
function c95515518.spfilter(c,e,tp)
	return c:IsSetCard(0x109) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测
function c95515518.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只满足特殊召唤条件的「天气」怪兽
		and Duel.IsExistingMatchingCard(c95515518.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁中的操作信息：从除外区特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果①的处理：将除外的1只「天气」怪兽特殊召唤
function c95515518.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择除外的1只满足条件的「天气」怪兽
	local g=Duel.SelectMatchingCard(tp,c95515518.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 赋予效果的发动代价：把自身除外
function c95515518.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身作为发动代价表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：可以被除外的卡
function c95515518.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 赋予效果的发动准备与目标选择
function c95515518.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c95515518.rmfilter(chkc) end
	-- 检查对方场上是否存在至少1只可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(c95515518.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可以被除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95515518.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁中的操作信息：除外选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 赋予效果的处理：暂时除外对象怪兽，并注册下个回合准备阶段返回场上的效果
function c95515518.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍在该效果的连锁中，则将其作为效果暂时除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 计算返回场上所需的准备阶段间隔数（若当前已是准备阶段或之前，则在下下个准备阶段返回，否则在下个准备阶段返回）
		local ct=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
		tc:RegisterFlagEffect(95515518,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,ct)
		-- 那只怪兽直到下个回合的准备阶段除外。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
		e2:SetLabelObject(tc)
		e2:SetCountLimit(1)
		e2:SetCondition(c95515518.retcon)
		e2:SetOperation(c95515518.retop)
		-- 将当前回合数记录在效果的Label中，用于后续判定
		e2:SetLabel(Duel.GetTurnCount())
		-- 注册该延迟返回场上的全局效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤条件：确定哪些怪兽可以获得该效果（必须是这张卡所连接区的「天气」效果怪兽）
function c95515518.eftg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109) and lg:IsContains(c)
end
-- 判定返回场上的条件：当前回合数不等于发动时的回合数，且该怪兽仍带有对应的标记
function c95515518.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 确保不是在发动效果的当个回合的准备阶段直接返回，且怪兽的标记未消失
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(95515518)~=0
end
-- 执行返回场上的操作
function c95515518.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 判定效果③的发动条件：连接召唤的这张卡被破坏
function c95515518.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤条件：额外卡组中的「虹天气 彩虹」，且可以被特殊召唤
function c95515518.spfilter2(c,e,tp)
	-- 检查卡号是否为「虹天气 彩虹」，是否能特殊召唤，以及额外怪兽区域或所连接区域是否有空位
	return c:IsCode(54178659) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的发动准备与合法性检测
function c95515518.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在可以特殊召唤的「虹天气 彩虹」
	if chk==0 then return Duel.IsExistingMatchingCard(c95515518.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的处理：从额外卡组特殊召唤1只「虹天气 彩虹」
function c95515518.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只「虹天气 彩虹」
	local g=Duel.SelectMatchingCard(tp,c95515518.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「虹天气 彩虹」以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
