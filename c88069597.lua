--プレデター・プランター
-- 效果：
-- 这张卡的控制者在每次自己准备阶段支付800基本分。或者不支付基本分让这张卡破坏。
-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只4星以下的「捕食植物」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c88069597.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段支付800基本分。或者不支付基本分让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c88069597.mtcon)
	e2:SetOperation(c88069597.mtop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只4星以下的「捕食植物」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88069597,0))  --"「捕食植物」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c88069597.sptg)
	e3:SetOperation(c88069597.spop)
	c:RegisterEffect(e3)
end
-- 定义准备阶段维持基本分支付效果的条件函数
function c88069597.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为这张卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 定义准备阶段维持基本分支付效果的处理函数
function c88069597.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付800基本分并由玩家选择是否支付
	if Duel.CheckLPCost(tp,800) and Duel.SelectYesNo(tp,aux.Stringid(88069597,1)) then  --"是否支付800基本分？"
		-- 让玩家支付800基本分
		Duel.PayLPCost(tp,800)
	else
		-- 因未支付维持基本分而将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 过滤条件：手卡·墓地中4星以下的「捕食植物」怪兽
function c88069597.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤效果的发动准备（Target）函数
function c88069597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c88069597.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤操作的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义特殊召唤效果的执行（Operation）函数
function c88069597.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍在场上，以及自己场上是否有空余的怪兽区域
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88069597.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试将选中的怪兽以表侧表示特殊召唤
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
