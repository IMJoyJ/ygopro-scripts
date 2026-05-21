--ゴルゴニック・グール
-- 效果：
-- 自己场上有「蛇头食尸鬼」存在的场合，支付300基本分才能发动。这张卡从手卡特殊召唤。「蛇头食尸鬼」的效果1回合可以使用最多2次。
function c90764875.initial_effect(c)
	-- 自己场上有「蛇头食尸鬼」存在的场合，支付300基本分才能发动。这张卡从手卡特殊召唤。「蛇头食尸鬼」的效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90764875,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(2,90764875)
	e1:SetCondition(c90764875.spcon)
	e1:SetCost(c90764875.spcost)
	e1:SetTarget(c90764875.sptg)
	e1:SetOperation(c90764875.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「蛇头食尸鬼」
function c90764875.cfilter(c)
	return c:IsFaceup() and c:IsCode(90764875)
end
-- 特殊召唤效果的发动条件函数
function c90764875.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「蛇头食尸鬼」
	return Duel.IsExistingMatchingCard(c90764875.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动代价（Cost）函数
function c90764875.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能支付300基本分
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 支付300基本分
	Duel.PayLPCost(tp,300)
end
-- 特殊召唤效果的发动目标（Target）函数
function c90764875.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理（Operation）函数
function c90764875.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
