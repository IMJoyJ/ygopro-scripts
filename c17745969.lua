--スーパービークロイド－モビルベース
-- 效果：
-- 「机人」融合怪兽＋「机人」怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的攻击力以下的攻击力的1只「机人」怪兽从卡组·额外卡组特殊召唤。
-- ②：自己·对方的结束阶段以这张卡以外的自己的主要怪兽区域1只「机人」怪兽为对象才能发动。那只自己怪兽回到持有者手卡，这张卡的位置向那个怪兽区域移动。
function c17745969.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用满足条件的融合怪兽和机人族怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c17745969.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x16),true)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的攻击力以下的攻击力的1只「机人」怪兽从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17745969,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,17745969)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c17745969.sptg)
	e1:SetOperation(c17745969.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段以这张卡以外的自己的主要怪兽区域1只「机人」怪兽为对象才能发动。那只自己怪兽回到持有者手卡，这张卡的位置向那个怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17745969,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c17745969.mvtg)
	e2:SetOperation(c17745969.mvop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数，筛选融合类型的机人族怪兽
function c17745969.matfilter(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x16)
end
-- 特殊召唤效果的目标过滤函数，检查对方场上是否存在满足条件的表侧表示怪兽
function c17745969.spfilter1(c,e,tp)
	-- 检查对方场上是否存在满足条件的表侧表示怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c17745969.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttack())
end
-- 特殊召唤效果的特殊召唤卡过滤函数，筛选攻击力不超过目标怪兽攻击力的机人族怪兽
function c17745969.spfilter2(c,e,tp,atk)
	return c:IsSetCard(0x16) and c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断目标怪兽是否在卡组且场上存在可用怪兽区
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 判断目标怪兽是否在额外卡组且存在可用的特殊召唤区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 特殊召唤效果的目标选择函数，选择对方场上的表侧表示怪兽
function c17745969.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c17745969.spfilter1(chkc,e,tp) end
	-- 判断是否满足特殊召唤效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(c17745969.spfilter1,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择对方场上的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c17745969.spfilter1,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤满足条件的机人族怪兽
function c17745969.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的机人族怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的机人族怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c17745969.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetAttack())
		if g:GetCount()>0 then
			-- 将符合条件的机人族怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 移动效果的目标过滤函数，筛选自己场上的机人族怪兽
function c17745969.mvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16) and c:IsAbleToHand() and c:GetSequence()<5
end
-- 移动效果的目标选择函数，选择自己场上的机人族怪兽
function c17745969.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c17745969.mvfilter(chkc) end
	-- 判断是否满足移动效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(c17745969.mvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的机人族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上的机人族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c17745969.mvfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置移动效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 移动效果的处理函数，将目标怪兽送回手牌并移动自身位置
function c17745969.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取移动效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断移动效果的处理条件是否满足
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and c:IsFaceup() and c:IsRelateToEffect(e) then
		local seq=tc:GetPreviousSequence()
		-- 将自身移动到目标怪兽原本所在的怪兽区域
		Duel.MoveSequence(c,seq)
	end
end
