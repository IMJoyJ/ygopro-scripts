--マナドゥム・トリロスークタ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己墓地1只2星调整为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成2星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
function c21368273.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己墓地1只2星调整为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21368273,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21368273)
	e1:SetCondition(c21368273.spcon)
	e1:SetTarget(c21368273.sptg)
	e1:SetOperation(c21368273.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上的调整任意数量为对象才能发动。那些怪兽的等级变成2星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21368273,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,21368274)
	e2:SetTarget(c21368273.lvtg)
	e2:SetOperation(c21368273.lvop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为同调召唤成功
function c21368273.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的墓地2星调整，用于特殊召唤
function c21368273.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的检索目标，判断是否满足条件
function c21368273.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21368273.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的调整
		and Duel.IsExistingTarget(c21368273.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地调整作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c21368273.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果，将目标卡特殊召唤并使其效果无效
function c21368273.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并进行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤满足条件的场上调整，用于等级变更
function c21368273.lvfilter(c)
	return c:IsType(TYPE_TUNER) and c:GetLevel()>0 and not c:IsLevel(2) and c:IsFaceup()
end
-- 设置等级变更效果的检索目标，判断是否满足条件
function c21368273.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21368273.lvfilter(chkc) end
	-- 判断场上是否存在满足条件的调整
	if chk==0 then return Duel.IsExistingTarget(c21368273.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上调整作为等级变更对象
	Duel.SelectTarget(tp,c21368273.lvfilter,tp,LOCATION_MZONE,0,1,6,nil)
end
-- 处理等级变更效果，将目标卡等级变为2星并限制非同调怪兽特殊召唤
function c21368273.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组并筛选出有效且表侧表示的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将目标卡等级变为2星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 设置效果，使玩家在本回合不能从额外卡组特殊召唤非同调怪兽
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c21368273.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制非同调怪兽从额外卡组特殊召唤
function c21368273.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
