--ネオスペース・コネクター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡·卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」守备表示特殊召唤。
-- ②：把这张卡解放，以自己墓地1只「新空间侠」怪兽或者「元素英雄 新宇侠」为对象才能发动。那只怪兽守备表示特殊召唤。
function c85840608.initial_effect(c)
	-- 将「元素英雄 新宇侠」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,89943723)
	-- ①：这张卡召唤成功时才能发动。从手卡·卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85840608,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,85840608)
	e1:SetTarget(c85840608.sptg1)
	e1:SetOperation(c85840608.spop1)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己墓地1只「新空间侠」怪兽或者「元素英雄 新宇侠」为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85840608,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85840609)
	e2:SetCost(c85840608.spcost2)
	e2:SetTarget(c85840608.sptg2)
	e2:SetOperation(c85840608.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为「新空间侠」怪兽或「元素英雄 新宇侠」，且能否以守备表示特殊召唤
function c85840608.spfilter(c,e,tp)
	return (c:IsSetCard(0x1f) or c:IsCode(89943723)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与合法性检查函数
function c85840608.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动阶段，检查自己的手卡或卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c85840608.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统注册效果处理信息：表示该效果包含从手卡或卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的效果处理函数
function c85840608.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上没有空余的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组中选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85840608.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动代价检查与执行函数
function c85840608.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备与对象选择函数
function c85840608.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85840608.spfilter(chkc,e,tp) end
	-- 在效果发动阶段，检查在解放自身后，自己场上是否有空余的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 在效果发动阶段，检查自己墓地是否存在至少1只可以作为效果对象的、满足特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c85840608.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地中1只满足特殊召唤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85840608.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统注册效果处理信息：表示该效果包含特殊召唤所选择的1只对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理函数
function c85840608.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的那只怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
