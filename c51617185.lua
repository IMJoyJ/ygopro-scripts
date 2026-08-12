--マシンナーズ・メガフォーム
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡解放才能发动。从手卡·卡组把「机甲部队·超大变形」以外的1只「机甲」怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的「机甲要塞」被送去自己墓地的场合，把那1只「机甲要塞」从墓地除外才能发动。这张卡特殊召唤。
function c51617185.initial_effect(c)
	-- ①：把这张卡解放才能发动。从手卡·卡组把「机甲部队·超大变形」以外的1只「机甲」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51617185,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,51617185)
	e1:SetCost(c51617185.spcost1)
	e1:SetTarget(c51617185.sptg1)
	e1:SetOperation(c51617185.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的「机甲要塞」被送去自己墓地的场合，把那1只「机甲要塞」从墓地除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51617185,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51617185)
	e2:SetCost(c51617185.spcost2)
	e2:SetTarget(c51617185.sptg2)
	e2:SetOperation(c51617185.spop2)
	c:RegisterEffect(e2)
end
-- 支付效果代价：解放自身
function c51617185.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可用于特殊召唤的怪兽（非此卡且为机甲族）
function c51617185.spfilter(c,e,tp)
	return c:IsSetCard(0x36) and not c:IsCode(51617185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足效果发动条件：场上存在空位且手牌或卡组中有符合条件的怪兽
function c51617185.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌或卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c51617185.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行效果处理：选择并特殊召唤符合条件的怪兽
function c51617185.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c51617185.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选被送去墓地的「机甲要塞」怪兽
function c51617185.cfilter(c,tp)
	return c:IsCode(5556499) and c:IsControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsAbleToRemoveAsCost()
end
-- 支付效果代价：除外一张符合条件的「机甲要塞」
function c51617185.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsContains(e:GetHandler()) and eg:IsExists(c51617185.cfilter,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=eg:FilterSelect(tp,c51617185.cfilter,1,1,nil,tp)
	-- 将选中的「机甲要塞」从墓地除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 判断是否满足效果发动条件：场上存在空位且此卡可特殊召唤
function c51617185.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果处理：将此卡特殊召唤到场上
function c51617185.spop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
