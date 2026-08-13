--スーパービークロイド－モビルベース
-- 效果：
-- 「机人」融合怪兽＋「机人」怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的攻击力以下的攻击力的1只「机人」怪兽从卡组·额外卡组特殊召唤。
-- ②：自己·对方的结束阶段以这张卡以外的自己的主要怪兽区域1只「机人」怪兽为对象才能发动。那只自己怪兽回到持有者手卡，这张卡的位置向那个怪兽区域移动。
function c17745969.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要以1只「机人」融合怪兽和1只「机人」怪兽作为融合素材。
	aux.AddFusionProcFun2(c,c17745969.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x16),true)
	-- 这个卡名的①的效果1回合只能使用1次。①：以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的攻击力以下的攻击力的1只「机人」怪兽从卡组·额外卡组特殊召唤。
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
-- 该函数用于筛选融合素材：素材怪兽必须是融合怪兽且属于「机人」系列（即「机人」融合怪兽）。
function c17745969.matfilter(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x16)
end
-- 该函数用于筛选①效果的对象：对方场上的表侧表示怪兽，并且我方卡组·额外卡组中存在攻击力不高于该怪兽攻击力的「机人」怪兽可供特殊召唤。
function c17745969.spfilter1(c,e,tp)
	-- 检查目标怪兽是否表侧表示，同时以目标怪兽的攻击力为参数，确认卡组·额外卡组中存在可特殊召唤的「机人」怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c17745969.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttack())
end
-- 该函数筛选可特殊召唤的「机人」怪兽：需属于「机人」系列、攻击力不高于指定值、能够被玩家特殊召唤；从卡组特殊召唤时需我方主要怪兽区有空位，从额外卡组特殊召唤时需有可供额外怪兽特殊召唤的格子。
function c17745969.spfilter2(c,e,tp,atk)
	return c:IsSetCard(0x16) and c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 候选卡位于卡组时，进行特殊召唤需要我方场上（主要怪兽区）存在可用的空格。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 候选卡位于额外卡组时，需要我方场上存在可用的额外怪兽区或连接区域，使其能被成功特殊召唤。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的发动目标处理：从对方场上选择1只表侧表示怪兽为对象，并设置效果处理时从卡组·额外卡组特殊召唤「机人」怪兽的信息。
function c17745969.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c17745969.spfilter1(chkc,e,tp) end
	-- 发动条件检查：确认对方场上有表侧表示怪兽，且我方存在可对应特殊召唤的「机人」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c17745969.spfilter1,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 向操作者显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足筛选条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c17745969.spfilter1,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：效果分类为特殊召唤，预计从卡组·额外卡组特殊召唤1只怪兽（实际卡片在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果处理：取得对象怪兽后，若对象仍与效果关联且为表侧表示，则从卡组·额外卡组选择1只攻击力不高于对象怪兽攻击力的「机人」怪兽特殊召唤。
function c17745969.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（之前选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组·额外卡组选择1只满足spfilter2条件的「机人」怪兽（攻击力不大于对象怪兽攻击力且可特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,c17745969.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetAttack())
		if g:GetCount()>0 then
			-- 将选择的「机人」怪兽以表侧攻击表示特殊召唤到操作者（我方）场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 该函数用于筛选②效果可选择的怪兽：必须是表侧表示、属于「机人」系列、能够返回手卡，且位于主要怪兽区域（格子编号<5，即非额外怪兽区）。
function c17745969.mvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16) and c:IsAbleToHand() and c:GetSequence()<5
end
-- ②效果的发动目标处理：在结束阶段选择这张卡以外的自己的主要怪兽区域1只「机人」怪兽为对象，并设置将其返回手卡的操作信息。
function c17745969.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c17745969.mvfilter(chkc) end
	-- 发动条件检查：确认自己的主要怪兽区域存在满足mvfilter条件的「机人」怪兽（且不是这张卡自身）。
	if chk==0 then return Duel.IsExistingTarget(c17745969.mvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作者显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足mvfilter条件的「机人」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c17745969.mvfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息：效果分类为返回手卡，将对象卡返回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：将对象怪兽返回持有者手卡；返回成功后，若这张卡仍表侧表示且与效果关联，则把这张卡移动到对象怪兽原本所在的主要怪兽区域。
function c17745969.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象（之前选择的「机人」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且控制者为自己，并将其返回持有者手卡（返回成功时处理后续移动）。
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and c:IsFaceup() and c:IsRelateToEffect(e) then
		local seq=tc:GetPreviousSequence()
		-- 将这张卡移动到对象怪兽返回手卡前所在的主要怪兽区域（用之前的区域序号设置新位置）。
		Duel.MoveSequence(c,seq)
	end
end
