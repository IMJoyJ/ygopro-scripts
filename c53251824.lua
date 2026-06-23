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
		-- 这张卡召唤·特殊召唤的回合的自己主要阶段才能发动1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(53251824)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 注册用于记录该卡在召唤成功时的flag标记
		ge1:SetOperation(aux.sumreg)
		-- 将效果ge1注册给全局环境
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(53251824)
		-- 将效果ge2注册给全局环境
		Duel.RegisterEffect(ge2,0)
	end
end
-- 判断当前回合是否为该卡召唤或特殊召唤的回合
function c53251824.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53251824)>0
end
-- 过滤手牌中满足条件的「急袭猛禽」怪兽（等级不超过4星）
function c53251824.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且手牌中有符合条件的怪兽
function c53251824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张符合条件的怪兽
		and Duel.IsExistingMatchingCard(c53251824.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡为手牌中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果处理：选择并特殊召唤符合条件的怪兽
function c53251824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c53251824.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
