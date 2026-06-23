--マシンナーズ・アンクラスペア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「机甲未分类备用兵」以外的1只「机甲」怪兽送去墓地。
function c45674286.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45674286,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,45674286)
	e1:SetCondition(c45674286.spcon)
	e1:SetTarget(c45674286.sptg)
	e1:SetOperation(c45674286.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「机甲未分类备用兵」以外的1只「机甲」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45674286,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,45674287)
	e2:SetTarget(c45674286.tgtg)
	e2:SetOperation(c45674286.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查这张卡不是因抽卡而加入手牌
function c45674286.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 判断是否满足特殊召唤的条件
function c45674286.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并设置不能特殊召唤机械族以外怪兽的效果
function c45674286.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local c=e:GetHandler()
	-- 设置不能特殊召唤非机械族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45674286.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制非机械族怪兽不能特殊召唤
function c45674286.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 过滤出「机甲」怪兽且不是本卡的卡片
function c45674286.tgfilter(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and not c:IsCode(45674286) and c:IsAbleToGrave()
end
-- 判断卡组中是否存在满足条件的「机甲」怪兽
function c45674286.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45674286.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行将符合条件的怪兽送去墓地的操作
function c45674286.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张满足条件的怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c45674286.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
