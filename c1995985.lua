--サイレント・ソードマン LV3
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡为对象的对方的魔法卡的效果无效化。
-- ②：自己准备阶段把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默剑士 LV5」特殊召唤。这个效果在这张卡召唤·特殊召唤·反转的回合不能发动。
function c1995985.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡为对象的对方的魔法卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c1995985.disop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默剑士 LV5」特殊召唤。这个效果在这张卡召唤·特殊召唤·反转的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1995985,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c1995985.spcon)
	e2:SetCost(c1995985.spcost)
	e2:SetTarget(c1995985.sptg)
	e2:SetOperation(c1995985.spop)
	c:RegisterEffect(e2)
	-- 登记召唤成功时的触发效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c1995985.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c1995985.lvup={74388798}
-- 当连锁处理时，若对方发动的是魔法卡且对象包含此卡，则使该效果无效
function c1995985.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsType(TYPE_SPELL) or rp==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsContains(e:GetHandler()) then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 在召唤成功时，为这张卡登记一个标记，表示在本回合不能再发动效果
function c1995985.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(1995985,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为自己的准备阶段且本回合未发动过效果
function c1995985.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段且本回合未发动过效果
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(1995985)==0
end
-- 支付将此卡送去墓地作为代价
function c1995985.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选手卡或卡组中「沉默剑士 LV5」的卡片
function c1995985.spfilter(c,e,tp)
	return c:IsCode(74388798) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 设置特殊召唤的条件，检查是否有满足条件的卡片
function c1995985.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在「沉默剑士 LV5」
		and Duel.IsExistingMatchingCard(c1995985.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，表示将要特殊召唤1只「沉默剑士 LV5」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤操作，选择并特殊召唤「沉默剑士 LV5」
function c1995985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「沉默剑士 LV5」卡片
	local g=Duel.SelectMatchingCard(tp,c1995985.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
