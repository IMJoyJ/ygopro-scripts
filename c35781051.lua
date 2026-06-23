--アルカナフォースⅢ－THE EMPRESS
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：每次对方对怪兽的通常召唤成功可以从手卡把1只名字带有「秘仪之力」的怪兽在自己场上特殊召唤。
-- ●里：每次对方对怪兽的通常召唤成功自己把手卡1张卡送去墓地。
function c35781051.initial_effect(c)
	-- 为卡片注册投掷硬币的诱发效果，当召唤·反转召唤·特殊召唤成功时触发
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：每次对方对怪兽的通常召唤成功可以从手卡把1只名字带有「秘仪之力」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35781051,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c35781051.spcon)
	e1:SetTarget(c35781051.sptg)
	e1:SetOperation(c35781051.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
	-- ●里：每次对方对怪兽的通常召唤成功自己把手卡1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35781051,2))  --"手牌送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c35781051.tgcon)
	e3:SetTarget(c35781051.tgtg)
	e3:SetOperation(c35781051.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_MSET)
	c:RegisterEffect(e4)
end
-- 效果条件：对方召唤成功且硬币结果为正面（表）
function c35781051.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 过滤函数：筛选手卡中名字带有「秘仪之力」且可特殊召唤的怪兽
function c35781051.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断条件：检查场上是否有空位且手卡是否存在满足条件的怪兽
function c35781051.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c35781051.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择并特殊召唤符合条件的怪兽
function c35781051.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，无空位则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1张手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c35781051.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件：对方召唤成功且硬币结果为反面（里）
function c35781051.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 判断条件：设置操作信息，准备送去墓地1张卡
function c35781051.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：准备送去墓地1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择并送去墓地1张手卡
function c35781051.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()~=0 then
		-- 执行送去墓地操作
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
