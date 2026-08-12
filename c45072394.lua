--鉄の檻
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上1只怪兽送去墓地。场地区域有「急流山的金宫」存在的场合，也能作为代替把对方场上的怪兽送去墓地。
-- ②：自己准备阶段，以这张卡的①的效果送去自己或者对方的墓地的1只怪兽为对象才能发动。这张卡破坏，那只怪兽在自己场上特殊召唤。
function c45072394.initial_effect(c)
	-- 记录此卡与「急流山的金宫」之间的关联
	aux.AddCodeList(c,72283691)
	-- ①：作为这张卡的发动时的效果处理，自己场上1只怪兽送去墓地。场地区域有「急流山的金宫」存在的场合，也能作为代替把对方场上的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45072394+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c45072394.target)
	e1:SetOperation(c45072394.operation)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段，以这张卡的①的效果送去自己或者对方的墓地的1只怪兽为对象才能发动。这张卡破坏，那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45072394,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45072394.spcon)
	e2:SetTarget(c45072394.sptg)
	e2:SetOperation(c45072394.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判断是否可以发动效果，若场地区域存在「急流山的金宫」则允许选择对方怪兽送去墓地
function c45072394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	-- 判断场地区域是否存在「急流山的金宫」
	if Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) then
		loc=LOCATION_MZONE
	end
	-- 检查是否有满足条件的怪兽可以送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,loc,1,nil) end
end
-- 处理效果发动时的墓地操作，选择并送去怪兽到墓地
function c45072394.operation(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	-- 判断场地区域是否存在「急流山的金宫」
	if Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) then
		loc=LOCATION_MZONE
	end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,loc,1,1,nil):GetFirst()
	-- 将选中的怪兽送去墓地并记录其信息
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		tc:RegisterFlagEffect(45072394,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
	end
end
-- 判断是否为当前玩家的准备阶段
function c45072394.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家为发动者
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数，用于筛选可特殊召唤的怪兽
function c45072394.filter(c,e,tp)
	return c==e:GetLabelObject():GetLabelObject() and c:GetFlagEffect(45072394)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择逻辑
function c45072394.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c45072394.filter(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的怪兽可作为特殊召唤对象
		and Duel.IsExistingTarget(c45072394.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c45072394.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，标记将要破坏此卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息，标记将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，破坏此卡并特殊召唤怪兽
function c45072394.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认此卡与目标怪兽均有效
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
