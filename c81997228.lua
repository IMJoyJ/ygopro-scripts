--プランキッズ・ハウスバトラー
-- 效果：
-- 「调皮宝贝·火灯娃」＋「调皮宝贝·水滴娃」＋「调皮宝贝·脉冲娃」
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。对方场上的怪兽全部破坏。这个效果在对方回合也能发动。
-- ②：这张卡被对方送去墓地的场合，以融合怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c81997228.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「调皮宝贝·火灯娃」＋「调皮宝贝·水滴娃」＋「调皮宝贝·脉冲娃」
	aux.AddFusionProcCode3(c,81119816,18236002,55725117,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该怪兽只能通过融合召唤的方式特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：把这张卡解放才能发动。对方场上的怪兽全部破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81997228,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c81997228.descost)
	e1:SetTarget(c81997228.destg)
	e1:SetOperation(c81997228.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方送去墓地的场合，以融合怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81997228,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,81997228)
	e2:SetCondition(c81997228.spcon)
	e2:SetTarget(c81997228.sptg)
	e2:SetOperation(c81997228.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上或墓地中可以代替解放而除外的「调皮宝贝·喵喵猫」
function c81997228.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 破坏效果的发动代价（解放自身或使用「调皮宝贝·喵喵猫」代替解放除外）
function c81997228.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上及墓地中满足代替解放条件的卡片组
	local g=Duel.GetMatchingGroup(c81997228.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then return #g>0 end
	local tc
	if #g>1 then
		-- 提示玩家选择要解放或代替解放除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将代替解放的卡片表侧表示除外作为发动代价
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将自身解放作为发动代价
		Duel.Release(tc,REASON_COST)
	end
end
-- 破坏效果的发动准备（检查对方场上是否有怪兽并设置破坏操作信息）
function c81997228.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁处理中的操作信息为破坏对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的实际处理（破坏对方场上的所有怪兽）
function c81997228.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 因效果将获取到的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件（这张卡被对方送去墓地且原本由自己控制）
function c81997228.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤自己墓地中非融合怪兽且可以特殊召唤的怪兽
function c81997228.spfilter(c,e,tp)
	return not c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位、选择墓地中的非融合怪兽为对象并设置特殊召唤操作信息）
function c81997228.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c81997228.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的非融合怪兽
		and Duel.IsExistingTarget(c81997228.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的非融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81997228.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理（将作为对象的怪兽特殊召唤）
function c81997228.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
