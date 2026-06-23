--S－Force ラプスウェル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：从手卡把1张「治安战警队」卡除外才能发动。自己的「治安战警队」怪兽的正对面的对方怪兽全部破坏。
function c27383719.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27383719,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27383719)
	e1:SetTarget(c27383719.sptg)
	e1:SetOperation(c27383719.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡把1张「治安战警队」卡除外才能发动。自己的「治安战警队」怪兽的正对面的对方怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(27383719,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27383720)
	e2:SetCost(c27383719.descost)
	e2:SetTarget(c27383719.destg)
	e2:SetOperation(c27383719.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽且可以特殊召唤为对象
function c27383719.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and not c:IsCode(27383719)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向/发动检查与目标选择
function c27383719.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27383719.filter(chkc,e,tp) end
	-- 检查自己场上的可特殊召唤的怪兽区域是否大于0
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己墓地是否存在符合条件的「治安战警队」怪兽
		and Duel.IsExistingTarget(c27383719.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「治安战警队」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c27383719.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理
function c27383719.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁被选为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的对象怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：用于发动效果的Cost，检查是否为可以除外的「治安战警队」卡片（或受其它卡效果影响进行代替的卡）
function c27383719.costfilter(c,e,tp)
	if c:IsHasEffect(55049722,tp) then
		return e:GetHandler():IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	elseif c:IsHasEffect(11642993,tp) then
		return e:GetHandler():IsSetCard(0x156) and not c:IsCode(11642993)
			and c:IsSetCard(0x156) and c:IsAbleToGraveAsCost()
	elseif c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	end
end
-- 破坏效果的Cost处理
function c27383719.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可作为Cost除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取可用作Cost除外的卡片组
	local cg=Duel.GetMatchingGroup(c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if cg:IsExists(Card.IsHasEffect,1,nil,11642993,tp) then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	end
	-- 选择1张要除外以作为发动Cost的卡
	local tg=Duel.SelectMatchingCard(tp,c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(11642993,tp)
	if te then
		-- 展示代替除外Cost的卡片
		Duel.Hint(HINT_CARD,0,11642993)
		te:UseCountLimit(tp)
		-- 将代替除外的卡片送入墓地以支付Cost
		Duel.SendtoGrave(tg,REASON_COST+REASON_REPLACE)
	else
		local te2=tg:GetFirst():IsHasEffect(55049722,tp)
		if te2 then
			te2:UseCountLimit(tp)
			-- 将代替除外的卡表侧表示除外以支付Cost
			Duel.Remove(tg,POS_FACEUP,REASON_COST+REASON_REPLACE)
		else
			-- 将手牌中选中的「治安战警队」卡表侧表示除外以支付Cost
			Duel.Remove(tg,POS_FACEUP,REASON_COST)
		end
	end
end
-- 过滤条件：自己场上表侧表示的「治安战警队」怪兽
function c27383719.ggfilter(c,tp)
	return c:IsSetCard(0x156) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤条件：位于自己「治安战警队」怪兽正对面的对方场上的怪兽
function c27383719.desfilter(c,tp)
	local g=c:GetColumnGroup()
	return g:IsExists(c27383719.ggfilter,1,nil,tp)
end
-- 破坏效果的靶向/发动检查与目标选择
function c27383719.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取所有符合破坏条件的对方怪兽
	local g=Duel.GetMatchingGroup(c27383719.desfilter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>0 end
	-- 设置操作信息：破坏所有选定的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的处理
function c27383719.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有符合破坏条件的对方怪兽
	local g=Duel.GetMatchingGroup(c27383719.desfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 破坏所有符合条件的对方怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
