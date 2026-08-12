--十二獣ラム
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 羊冲」以外的自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡为对象的对方的陷阱卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
function c4145852.initial_effect(c)
	-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 羊冲」以外的自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4145852,0))  --"墓地「十二兽」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c4145852.spcon)
	e1:SetTarget(c4145852.sptg)
	e1:SetOperation(c4145852.spop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡为对象的对方的陷阱卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4145852,1))  --"陷阱卡的效果发动无效（十二兽 羊冲）"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c4145852.discon)
	e2:SetCost(c4145852.discost)
	e2:SetTarget(c4145852.distg)
	e2:SetOperation(c4145852.disop)
	c:RegisterEffect(e2)
end
-- 判断破坏原因是否为效果或战斗破坏
function c4145852.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 筛选满足条件的墓地「十二兽」怪兽（非羊冲本身，可特殊召唤）
function c4145852.spfilter(c,e,tp)
	return c:IsSetCard(0xf1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(4145852)
end
-- 设置特殊召唤效果的发动条件，检查是否有满足条件的墓地目标
function c4145852.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4145852.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的「十二兽」怪兽
		and Duel.IsExistingTarget(c4145852.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c4145852.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c4145852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足陷阱无效效果的发动条件
function c4145852.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 判断连锁发动的是陷阱卡且可被无效
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and tg and tg:IsContains(c)
end
-- 支付陷阱无效效果的代价，移除一张超量素材
function c4145852.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置陷阱无效效果的目标和处理信息
function c4145852.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息，确定无效的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行陷阱无效效果，使对方陷阱发动无效
function c4145852.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
