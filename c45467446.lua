--白き霊龍
-- 效果：
-- 这个卡名在规则上也当作「青眼」卡使用。
-- ①：这张卡只要在手卡·墓地存在，当作通常怪兽使用。
-- ②：这张卡召唤·特殊召唤时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
-- ③：自己·对方回合，对方场上有怪兽存在的场合，把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
function c45467446.initial_effect(c)
	-- 注册卡片效果，使此卡在规则上也当作「青眼」卡使用
	aux.AddCodeList(c,89631139)
	-- ①：这张卡只要在手卡·墓地存在，当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c45467446.rmtg)
	e3:SetOperation(c45467446.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：自己·对方回合，对方场上有怪兽存在的场合，把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c45467446.spcon)
	e5:SetCost(c45467446.spcost)
	e5:SetTarget(c45467446.sptg)
	e5:SetOperation(c45467446.spop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于判断目标卡片是否为魔法或陷阱卡且能被除外
function c45467446.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 设置效果目标，选择对方场上的魔法或陷阱卡作为除外对象
function c45467446.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c45467446.rmfilter(chkc) end
	-- 检查是否有满足条件的魔法或陷阱卡可作为除外对象
	if chk==0 then return Duel.IsExistingTarget(c45467446.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的魔法或陷阱卡作为除外对象
	local g=Duel.SelectTarget(tp,c45467446.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，将选中的卡除外
function c45467446.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断对方场上有怪兽存在
function c45467446.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 设置效果成本，解放自身作为代价
function c45467446.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果成本
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于判断手牌中是否有「青眼白龙」可特殊召唤
function c45467446.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标，检查是否有「青眼白龙」可特殊召唤
function c45467446.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌中是否有「青眼白龙」可特殊召唤
		and Duel.IsExistingMatchingCard(c45467446.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果操作信息，指定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，从手牌中特殊召唤「青眼白龙」
function c45467446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「青眼白龙」作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,c45467446.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「青眼白龙」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
