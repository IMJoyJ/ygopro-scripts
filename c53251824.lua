--RR－バニシング・レイニアス
-- 效果：
-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动1次。从手卡把1只4星以下的「急袭猛禽」怪兽特殊召唤。
function c53251824.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动1次。从手卡把1只4星以下的「急袭猛禽」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c53251824.spcon)
	e1:SetTarget(c53251824.sptg)
	e1:SetOperation(c53251824.spop)
	c:RegisterEffect(e1)
	if not c53251824.global_check then
		c53251824.global_check=true
		-- “这张卡召唤·特殊召唤的回合”这一条件部分的辅助记录效果。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(53251824)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的操作为aux.sumreg，在怪兽召唤成功时给该怪兽打上召唤标记，用于记录“这张卡召唤的回合”。
		ge1:SetOperation(aux.sumreg)
		-- 将监听通常召唤成功的全局辅助效果注册到全场，使任何怪兽通常召唤成功时都能触发该标记记录。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(53251824)
		-- 将监听特殊召唤成功的全局辅助效果副本注册到全场，使任何怪兽特殊召唤成功时都能触发该标记记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果发动条件判定：本卡带有标记53251824（即本回合已被召唤或特殊召唤过）时才满足发动条件。
function c53251824.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53251824)>0
end
-- 特殊召唤的怪兽筛选条件：手牌的「急袭猛禽」怪兽、等级4以下、且能够被特殊召唤。
function c53251824.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点检查：自己主要怪兽区有空位，且手牌存在1只以上符合条件的「急袭猛禽」怪兽才能发动。
function c53251824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足spfilter条件的「急袭猛禽」怪兽。
		and Duel.IsExistingMatchingCard(c53251824.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：此次效果涉及从手牌进行1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若主怪兽区无空位则直接结束；否则提示选择并让玩家从手牌选1只符合条件的「急袭猛禽」怪兽，正面表示特殊召唤到自己的主要怪兽区。
function c53251824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主怪兽区是否有空格，如果没有空格则不能进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示当前玩家选择要特殊召唤的卡，显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足spfilter条件的「急袭猛禽」怪兽（从自己手牌中选，最多1张）。
	local g=Duel.SelectMatchingCard(tp,c53251824.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（sumtype=0，nocheck=false，nolimit=false）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
