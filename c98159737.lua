--天威龍－アーダラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外，以这张卡以外的除外的1只自己的幻龙族怪兽为对象才能发动。那只怪兽加入手卡。
function c98159737.initial_effect(c)
	-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98159737,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98159737)
	e1:SetCondition(c98159737.spcon)
	e1:SetTarget(c98159737.sptg)
	e1:SetOperation(c98159737.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外，以这张卡以外的除外的1只自己的幻龙族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98159737,1))  --"回收除外的卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,98159738)
	e2:SetCondition(c98159737.thcon)
	-- 设置效果的发动成本（Cost）：把手卡·墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c98159737.thtg)
	e2:SetOperation(c98159737.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的效果怪兽
function c98159737.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上没有效果怪兽存在
function c98159737.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的效果怪兽，若不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(c98159737.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备（Target）：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c98159737.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）：将这张卡特殊召唤
function c98159737.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：效果怪兽以外的表侧表示怪兽
function c98159737.thcfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上有效果怪兽以外的表侧表示怪兽存在
function c98159737.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在效果怪兽以外的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c98159737.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：除外的表侧表示的幻龙族怪兽，且可以加入手卡
function c98159737.thfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsFaceup()
end
-- 效果②的发动准备（Target）：选择除自身以外的、除外的1只自己的幻龙族怪兽为对象，并设置加入手卡的操作信息
function c98159737.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c98159737.thfilter(chkc) and chkc~=c end
	-- 检查除外区是否存在除自身以外的、满足条件的幻龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c98159737.thfilter,tp,LOCATION_REMOVED,0,1,c) end
	-- 在客户端显示提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除自身以外的、除外的1只自己的幻龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98159737.thfilter,tp,LOCATION_REMOVED,0,1,1,c)
	-- 设置加入手卡的操作信息：将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理（Operation）：将作为对象的怪兽加入手卡
function c98159737.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
