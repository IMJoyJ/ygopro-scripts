--深淵の獣アルベル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「阿不思的落胤」使用。
-- ②：这张卡召唤·特殊召唤的场合，可以丢弃1张手卡，以对方的场上·墓地1只龙族怪兽为对象，从以下效果选择1个发动。
-- ●这张卡送去墓地，作为对象的场上的怪兽的控制权直到结束阶段得到。
-- ●这张卡送去墓地，作为对象的墓地的怪兽在自己场上特殊召唤。
function c45005708.initial_effect(c)
	-- 使该卡在场上和墓地时视为「阿不思的落胤」使用
	aux.EnableChangeCode(c,68468459,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡召唤·特殊召唤的场合，可以丢弃1张手卡，以对方的场上·墓地1只龙族怪兽为对象，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,45005708)
	e1:SetCost(c45005708.cost)
	e1:SetTarget(c45005708.tg)
	e1:SetOperation(c45005708.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查玩家手牌是否存在可丢弃的卡牌，若存在则丢弃1张手牌作为代价
function c45005708.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃玩家1张手牌作为代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上满足条件的龙族怪兽，用于选择控制权变更对象
function c45005708.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControlerCanBeChanged()
end
-- 过滤墓地满足条件的龙族怪兽，用于选择特殊召唤对象
function c45005708.filter2(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件和目标选择逻辑，包括选择效果选项和设置操作信息
function c45005708.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45005708.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45005708.filter2(chkc,e,tp)
		end
	end
	local c=e:GetHandler()
	-- 检查对方场上是否存在满足条件的龙族怪兽
	local b1=Duel.IsExistingTarget(c45005708.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方墓地是否存在满足条件的龙族怪兽且己方有可用怪兽区
	local b2=Duel.IsExistingTarget(c45005708.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp) and Duel.GetMZoneCount(tp,c)>0
	if chk==0 then return c:IsAbleToGrave() and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 当两个选项都可用时，让玩家选择其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(45005708,0),aux.Stringid(45005708,1))  --"得到对方场上的怪兽的控制权/特殊召唤对方墓地的怪兽"
	elseif b1 then
		-- 当只有控制权变更选项可用时，让玩家选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(45005708,0))  --"得到对方场上的怪兽的控制权"
	else
		-- 当只有特殊召唤选项可用时，让玩家选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(45005708,1))+1  --"特殊召唤对方墓地的怪兽"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择场上满足条件的龙族怪兽作为控制权变更对象
		local g=Duel.SelectTarget(tp,c45005708.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息为控制权变更效果
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地满足条件的龙族怪兽作为特殊召唤对象
		local g=Duel.SelectTarget(tp,c45005708.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 设置操作信息为特殊召唤效果
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
	-- 设置操作信息为将自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
end
-- 设置效果的处理逻辑，根据选择的效果执行控制权变更或特殊召唤
function c45005708.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认自身和目标怪兽仍存在于游戏中且未被无效化
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	if c:GetLocation()~=LOCATION_GRAVE or not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		-- 将目标怪兽的控制权交给玩家直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	else
		-- 将目标怪兽特殊召唤到玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
