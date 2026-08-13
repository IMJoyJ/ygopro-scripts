--ガスタへの追風
-- 效果：
-- 「薰风」怪兽才能装备。这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽不会被对方的效果破坏。
-- ②：可以把装备怪兽的等级·阶级的以下效果发动。
-- ●4以下：和装备怪兽种族不同的1只「薰风」怪兽从卡组特殊召唤。
-- ●5以上：从卡组把1只1星调整特殊召唤。
-- ③：把墓地的这张卡除外，从手卡丢弃1只风属性怪兽才能发动。从卡组把1张「薰风」魔法·陷阱卡加入手卡。
function c1187243.initial_effect(c)
	-- 「薰风」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1187243.target)
	e1:SetOperation(c1187243.operation)
	c:RegisterEffect(e1)
	-- 「薰风」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c1187243.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置‘不会被对方的效果破坏’的判定条件：仅当破坏效果来自对方时，装备怪兽免于破坏。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ●4以下：和装备怪兽种族不同的1只「薰风」怪兽从卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1187243,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,1187243)
	e4:SetCondition(c1187243.spcon1)
	e4:SetTarget(c1187243.sptg1)
	e4:SetOperation(c1187243.spop1)
	c:RegisterEffect(e4)
	-- ●5以上：从卡组把1只1星调整特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(1187243,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,1187243)
	e5:SetCondition(c1187243.spcon2)
	e5:SetTarget(c1187243.sptg2)
	e5:SetOperation(c1187243.spop2)
	c:RegisterEffect(e5)
	-- ③：把墓地的这张卡除外，从手卡丢弃1只风属性怪兽才能发动。从卡组把1张「薰风」魔法·陷阱卡加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(1187243,2))
	e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,1187244)
	e6:SetCost(c1187243.thcost)
	e6:SetTarget(c1187243.thtg)
	e6:SetOperation(c1187243.thop)
	c:RegisterEffect(e6)
end
-- 装备限制条件：此卡只能装备给卡名含有‘薰风’字段的怪兽。
function c1187243.eqlimit(e,c)
	return c:IsSetCard(0x10)
end
-- 筛选表侧表示且持有‘薰风’字段的怪兽，用于选择装备对象。
function c1187243.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10)
end
-- 装备魔法的发动处理：选择场上1只表侧表示‘薰风’怪兽作为装备对象，并设置装备操作信息。
function c1187243.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1187243.filter(chkc) end
	-- 发动合法性检查：确认场上存在1只表侧表示且为‘薰风’字段的怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c1187243.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家弹出‘请选择要装备的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 将场上1只表侧表示‘薰风’怪兽选为装备对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c1187243.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将要进行装备魔法卡的装备处理。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法的效果处理：若此卡和目标怪兽均仍与连锁相关且目标表侧表示，则将此卡装备给目标怪兽。
function c1187243.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- ②‘4以下’分支的发动条件：装备怪兽的等级或阶级在4以下。
function c1187243.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:IsLevelBelow(4) or ec:IsRankBelow(4))
end
-- 筛选可特殊召唤的怪兽：与装备怪兽种族不同的‘薰风’怪兽。
function c1187243.spfilter1(c,e,tp,race)
	return not c:IsRace(race) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②‘4以下’分支的发动目标：确认有可用怪兽区域且卡组存在符合条件的‘薰风’怪兽，并设置特殊召唤操作信息。
function c1187243.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 发动合法性检查：有可用怪兽区域，且卡组中存在与装备怪兽种族不同的‘薰风’怪兽可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c1187243.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,ec:GetRace()) end
	-- 设置操作信息：本次处理将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②‘4以下’分支的效果处理：若场上仍有空格且装备怪兽仍存在，则从卡组选1只与装备怪兽种族不同的‘薰风’怪兽表侧表示特殊召唤。
function c1187243.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己没有可用的主要怪兽区域则效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and ec:IsFaceup() and c:IsRelateToEffect(e) then
		-- 给玩家弹出‘请选择要特殊召唤的卡’的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选出1只符合种族不同条件且可特殊召唤的‘薰风’怪兽。
		local g=Duel.SelectMatchingCard(tp,c1187243.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec:GetRace())
		if g:GetCount()>0 then
			-- 将选出的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②‘5以上’分支的发动条件：装备怪兽的等级或阶级在5以上。
function c1187243.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:IsLevelAbove(5) or ec:IsRankAbove(5))
end
-- 筛选可特殊召唤的怪兽：1星调整怪兽。
function c1187243.spfilter2(c,e,tp)
	return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②‘5以上’分支的发动目标：确认有可用怪兽区域且卡组存在1星调整，并设置特殊召唤操作信息。
function c1187243.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：有可用怪兽区域，且卡组中存在1星调整怪兽可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c1187243.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次处理将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②‘5以上’分支的效果处理：若场上有空格，则从卡组选1只1星调整怪兽表侧表示特殊召唤。
function c1187243.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己没有可用的主要怪兽区域则效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家弹出‘请选择要特殊召唤的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选出1只1星调整怪兽。
	local g=Duel.SelectMatchingCard(tp,c1187243.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的调整怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③的cost筛选：风属性怪兽且可以从手卡丢弃。
function c1187243.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable()
end
-- ③的发动代价：将墓地的此卡除外，并从手卡丢弃1只风属性怪兽。
function c1187243.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：此卡可以从墓地除外，且手卡存在可以丢弃的风属性怪兽。
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c1187243.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将此卡从墓地除外作为cost。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡选择并丢弃1只风属性怪兽作为cost。
	Duel.DiscardHand(tp,c1187243.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检索目标筛选：卡组中‘薰风’字段的魔法·陷阱卡且可以加入手卡。
function c1187243.thfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③的发动目标：确认卡组中存在‘薰风’魔法·陷阱卡，并设置检索加入手卡的操作信息。
function c1187243.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在符合条件的‘薰风’魔法·陷阱卡可以加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1187243.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的效果处理：从卡组选1张‘薰风’魔法·陷阱卡加入手牌，并让对方确认。
function c1187243.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家弹出‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选出1张‘薰风’魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c1187243.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡加入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
