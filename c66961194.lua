--ロード・オブ・ドラゴン－ドラゴンの独裁者－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组把1只「青眼白龙」送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡丢弃1只「青眼白龙」或者1张有那个卡名记述的卡，以自己墓地1只「青眼」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：只要自己场上有「青眼」怪兽存在，对方选择自身怪兽的攻击对象之际，那个攻击对象由自己选择。
function c66961194.initial_effect(c)
	-- 注册本卡记述了「青眼白龙」的卡片密码
	aux.AddCodeList(c,89631139)
	-- ①：从手卡·卡组把1只「青眼白龙」送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66961194,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,66961194)
	e1:SetCost(c66961194.spcost1)
	e1:SetTarget(c66961194.sptg1)
	e1:SetOperation(c66961194.spop1)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1只「青眼白龙」或者1张有那个卡名记述的卡，以自己墓地1只「青眼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66961194,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66961195)
	e2:SetCost(c66961194.spcost2)
	e2:SetTarget(c66961194.sptg2)
	e2:SetOperation(c66961194.spop2)
	c:RegisterEffect(e2)
	-- ③：只要自己场上有「青眼」怪兽存在，对方选择自身怪兽的攻击对象之际，那个攻击对象由自己选择。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c66961194.podcond)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
-- 过滤手卡·卡组中可以作为发动代价送去墓地的「青眼白龙」
function c66961194.spcostfilter1(c)
	return c:IsCode(89631139) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价处理：从手卡·卡组将1只「青眼白龙」送去墓地
function c66961194.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组是否存在可以作为代价送去墓地的「青眼白龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c66961194.spcostfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡或卡组选择1张「青眼白龙」
	local g=Duel.SelectMatchingCard(tp,c66961194.spcostfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡片作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备与合法性检查
function c66961194.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤
function c66961194.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡中可以丢弃的「青眼白龙」或记述了「青眼白龙」的卡片
function c66961194.spcostfilter2(c)
	-- 判断卡片是否为「青眼白龙」或记述了「青眼白龙」且可以丢弃
	return aux.IsCodeOrListed(c,89631139) and c:IsDiscardable()
end
-- 效果②的发动代价处理：从手卡丢弃1只「青眼白龙」或记述了该卡名的卡
function c66961194.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足丢弃条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c66961194.spcostfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择并丢弃1张满足条件的手卡作为发动代价
	Duel.DiscardHand(tp,c66961194.spcostfilter2,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤墓地中属于「青眼」系列且能特殊召唤的怪兽
function c66961194.spfilter2(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与选择对象
function c66961194.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66961194.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「青眼」怪兽
		and Duel.IsExistingTarget(c66961194.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只「青眼」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66961194.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将选中的「青眼」怪兽特殊召唤
function c66961194.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「青眼」怪兽
function c66961194.podfilter(c)
	return c:IsSetCard(0xdd) and c:IsFaceup()
end
-- 效果③的适用条件：自己场上存在「青眼」怪兽
function c66961194.podcond(e)
	local tp=e:GetOwnerPlayer()
	-- 检查自己场上是否存在表侧表示的「青眼」怪兽
	return Duel.IsExistingMatchingCard(c66961194.podfilter,tp,LOCATION_MZONE,0,1,nil)
end
