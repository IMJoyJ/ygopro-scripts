--転生炎獣ミラージュスタリオ
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「转生炎兽」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把炎属性以外的怪兽的效果发动。
-- ②：超量召唤的这张卡作为「转生炎兽」连接怪兽的连接素材送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
function c87327776.initial_effect(c)
	-- 设置超量召唤手续：3星怪兽×2。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「转生炎兽」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把炎属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87327776,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,87327776)
	e1:SetCost(c87327776.spcost)
	e1:SetTarget(c87327776.sptg)
	e1:SetOperation(c87327776.spop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡作为「转生炎兽」连接怪兽的连接素材送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87327776,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,87327777)
	e2:SetCondition(c87327776.thcon)
	e2:SetTarget(c87327776.thtg)
	e2:SetOperation(c87327776.thop)
	c:RegisterEffect(e2)
end
-- ①效果的代价值判定与支付：取除这张卡的1个超量素材。
function c87327776.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中可以守备表示特殊召唤的「转生炎兽」怪兽。
function c87327776.spfilter(c,e,tp)
	return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备与合法性检测（检查怪兽区域空位及卡组中是否存在可召唤的怪兽）。
function c87327776.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「转生炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c87327776.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组特殊召唤1只「转生炎兽」怪兽，并适用“不能发动炎属性以外的怪兽效果”的限制。
function c87327776.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前自己场上仍有可用的怪兽区域空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足条件的「转生炎兽」怪兽。
		local g=Duel.SelectMatchingCard(tp,c87327776.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把炎属性以外的怪兽的效果发动。/②：超量召唤的这张卡作为「转生炎兽」连接怪兽的连接素材送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c87327776.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能发动炎属性以外怪兽效果的限制注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能发动非炎属性怪兽的效果。
function c87327776.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsNonAttribute(ATTRIBUTE_FIRE)
end
-- ②效果的发动条件：超量召唤的这张卡作为「转生炎兽」连接怪兽的连接素材送去墓地。
function c87327776.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x119)
end
-- ②效果的发动准备与对象选择（选择场上1只怪兽为对象）。
function c87327776.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 检查场上是否存在可以返回手牌的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只可以返回手牌的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：将选中的对象怪兽送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：使作为对象的怪兽回到持有者手牌。
function c87327776.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
