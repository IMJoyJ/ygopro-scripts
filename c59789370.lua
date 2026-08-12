--機巧猪－伊服岐雹荒神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有攻击力和守备力的数值相同的机械族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只攻击力和守备力的数值相同的机械族怪兽为对象才能发动。攻击力和守备力的数值相同而持有比作为对象的怪兽低的等级的1只机械族怪兽从卡组送去墓地。作为对象的怪兽的攻击力·守备力上升送去墓地的怪兽的等级×100。
function c59789370.initial_effect(c)
	-- ①：自己场上有攻击力和守备力的数值相同的机械族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59789370,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,59789370)
	e1:SetCondition(c59789370.spcon)
	e1:SetTarget(c59789370.sptg)
	e1:SetOperation(c59789370.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只攻击力和守备力的数值相同的机械族怪兽为对象才能发动。攻击力和守备力的数值相同而持有比作为对象的怪兽低的等级的1只机械族怪兽从卡组送去墓地。作为对象的怪兽的攻击力·守备力上升送去墓地的怪兽的等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59789370,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,59789371)
	-- 将墓地的这张卡除外作为发动成本（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c59789370.tgtg)
	e2:SetOperation(c59789370.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、攻击力与守备力数值相同且是机械族的怪兽
function c59789370.cfilter(c)
	-- 检查卡片是否为表侧表示、攻击力与守备力数值相同且是机械族
	return c:IsFaceup() and aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
end
-- 效果①的发动条件：自己场上存在攻击力与守备力数值相同的机械族怪兽
function c59789370.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件（表侧表示、攻守相同、机械族）的怪兽
	return Duel.IsExistingMatchingCard(c59789370.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备（Target）：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c59789370.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）：将这张卡从手卡特殊召唤
function c59789370.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件（选择对象）：自己场上表侧表示、等级大于0、攻守相同且是机械族，并且卡组中存在比其等级低的攻守相同机械族怪兽
function c59789370.tcfilter(c,tp)
	local lv=c:GetLevel()
	-- 检查卡片是否为表侧表示、等级大于0、攻击力与守备力数值相同且是机械族
	return c:IsFaceup() and lv>0 and aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
		-- 检查卡组中是否存在至少1只满足送墓过滤条件（攻守相同、机械族、等级低于lv）的怪兽
		and Duel.IsExistingMatchingCard(c59789370.tgfilter,tp,LOCATION_DECK,0,1,nil,lv)
end
-- 过滤条件（送去墓地）：卡组中攻守相同、等级低于指定数值、机械族且能送去墓地的怪兽
function c59789370.tgfilter(c,lv)
	-- 检查卡片是否攻击力与守备力数值相同，且等级低于作为对象的怪兽的等级
	return aux.AtkEqualsDef(c) and c:GetLevel()<lv
		and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 效果②的发动准备（Target）：选择自己场上1只符合条件的机械族怪兽作为对象，并设置送去墓地的操作信息
function c59789370.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59789370.tcfilter(chkc,tp) end
	-- 检查自己场上是否存在可以作为效果对象的符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c59789370.tcfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59789370.tcfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置送去墓地的操作信息，表示将从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）：将卡组中符合条件的怪兽送去墓地，并使作为对象的怪兽的攻击力·守备力上升送去墓地怪兽等级×100的数值
function c59789370.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只等级低于对象怪兽、攻守相同的机械族怪兽
	local sg=Duel.SelectMatchingCard(tp,c59789370.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
	local sc=sg:GetFirst()
	-- 将选择的怪兽送去墓地，并确认其已成功送去墓地
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) then
		local lv=sc:GetLevel()
		-- 作为对象的怪兽的攻击力·守备力上升送去墓地的怪兽的等级×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
