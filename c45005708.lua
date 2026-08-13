--深淵の獣アルベル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「阿不思的落胤」使用。
-- ②：这张卡召唤·特殊召唤的场合，可以丢弃1张手卡，以对方的场上·墓地1只龙族怪兽为对象，从以下效果选择1个发动。
-- ●这张卡送去墓地，作为对象的场上的怪兽的控制权直到结束阶段得到。
-- ●这张卡送去墓地，作为对象的墓地的怪兽在自己场上特殊召唤。
function c45005708.initial_effect(c)
	-- 为这张卡注册①效果：只要这张卡在场上·墓地存在，卡名当作「阿不思的落胤」使用。
	aux.EnableChangeCode(c,68468459,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次；②：这张卡召唤·特殊召唤的场合，可以丢弃1张手卡，以对方的场上·墓地1只龙族怪兽为对象，从以下效果选择1个发动。
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
-- ②效果的代价函数：发动时需要丢弃1张手卡作为代价。
function c45005708.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择1张卡丢弃，丢弃原因记为COST+DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：对象为对方场上表侧表示的龙族怪兽，且其控制权可以被改变。
function c45005708.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControlerCanBeChanged()
end
-- 筛选条件：对象为对方墓地的龙族怪兽，且该怪兽可以被当前效果特殊召唤。
function c45005708.filter2(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标处理：根据两个分支选择对象，记录选择的分支，并设置对应的效果分类与操作信息。
function c45005708.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45005708.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45005708.filter2(chkc,e,tp)
		end
	end
	local c=e:GetHandler()
	-- 检查对方场上是否存在1只满足控制权夺取条件的龙族怪兽。
	local b1=Duel.IsExistingTarget(c45005708.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方墓地是否存在1只可被特殊召唤的龙族怪兽，且这张卡送去墓地后自己场上仍有可用的怪兽区空格。
	local b2=Duel.IsExistingTarget(c45005708.filter2,tp,0,LOCATION_GRAVE,1,nil,e,tp) and Duel.GetMZoneCount(tp,c)>0
	if chk==0 then return c:IsAbleToGrave() and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 两个分支都可用时，让玩家选择发动“得到控制权”还是“特殊召唤墓地怪兽”。
		op=Duel.SelectOption(tp,aux.Stringid(45005708,0),aux.Stringid(45005708,1))  --"得到对方场上的怪兽的控制权/特殊召唤对方墓地的怪兽"
	elseif b1 then
		-- 仅控制权分支可用时，直接选择该分支（op记为0）。
		op=Duel.SelectOption(tp,aux.Stringid(45005708,0))  --"得到对方场上的怪兽的控制权"
	else
		-- 仅特殊召唤分支可用时，选择该分支，并将返回值加1使op记为1。
		op=Duel.SelectOption(tp,aux.Stringid(45005708,1))+1  --"特殊召唤对方墓地的怪兽"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 提示玩家选择要改变控制权的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上1只符合条件的龙族怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,c45005708.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		-- 登记操作信息：本连锁包含改变控制权效果，对象为所选的怪兽。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择对方墓地1只符合条件的龙族怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,c45005708.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 登记操作信息：本连锁包含特殊召唤效果，对象为所选的怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
	-- 登记操作信息：本连锁还会把这张卡自身送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
end
-- ②效果的处理：先将这张卡送去墓地，然后根据之前选择的分支，执行获得控制权或特殊召唤对象的操作。
function c45005708.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 确认这张卡仍与效果关联，并将这张卡以效果原因送去墓地；若失败或未送去墓地，则效果不继续处理。
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	if c:GetLocation()~=LOCATION_GRAVE or not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		-- 分支1的处理：获得对象怪兽的控制权，直到结束阶段。
		Duel.GetControl(tc,tp,PHASE_END,1)
	else
		-- 分支2的处理：将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
