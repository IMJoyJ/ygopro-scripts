--ジェムナイト・アイオーラ
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，可以把自己墓地存在的1只名字带有「宝石」的怪兽从游戏中除外，选择自己墓地存在的1张名字带有「宝石骑士」的卡加入手卡。
function c45662855.initial_effect(c)
	-- 为这张卡添加二重怪兽属性：使这张卡在墓地或场上表侧表示时当作通常怪兽使用，并支持进行再度召唤变成效果怪兽。
	aux.EnableDualAttribute(c)
	-- 对应效果原文：●1回合1次，可以把自己墓地存在的1只名字带有「宝石」的怪兽从游戏中除外，选择自己墓地存在的1张名字带有「宝石骑士」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(45662855,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果的发动条件：只有这张卡处于再度召唤状态（作为效果怪兽使用）时才可发动。
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c45662855.cost)
	e1:SetTarget(c45662855.target)
	e1:SetOperation(c45662855.operation)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：从墓地选择1只名字带有「宝石」的怪兽作为除外代价，且同时存在可加入手卡的「宝石骑士」卡。
function c45662855.costfilter(c,tp)
	return c:IsSetCard(0x47) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 追加检查：存在至少1张「宝石骑士」卡能够成为这个效果的对象（排除作为代价的那张宝石怪兽）。
		and Duel.IsExistingTarget(c45662855.tgfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- 定义对象筛选函数：从墓地选择1张名字带有「宝石骑士」的卡，且该卡能够加入手卡。
function c45662855.tgfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 代价函数：设置Label为1表示尚未实际选择并除外代价，然后返回true允许效果发动；真正的选牌和除外放在目标处理阶段进行。
function c45662855.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 目标选择函数：先根据Label判断是否已处理代价，若未处理则先从墓地选择1只宝石怪兽除外，再选择1张宝石骑士卡作为对象，并设置回手牌的操作信息。
function c45662855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45662855.tgfilter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 在效果发动时若还未支付代价，检查是否存在1只可当作代价除外的「宝石」怪兽，且同时存在可加入手卡的「宝石骑士」对象。
			return Duel.IsExistingMatchingCard(c45662855.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		else
			-- 在代价已支付后，检查自己的墓地是否存在1张可加入手卡的「宝石骑士」卡作为对象。
			return Duel.IsExistingTarget(c45662855.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
		end
	end
	if e:GetLabel()==1 then
		-- 向玩家显示选择提示，要求从墓地选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地中选择1只满足条件的「宝石」怪兽作为将要除外的代价。
		local cg=Duel.SelectMatchingCard(tp,c45662855.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		-- 将选择的「宝石」怪兽以表侧表示除外，作为发动效果的成本。
		Duel.Remove(cg,POS_FACEUP,REASON_COST)
		e:SetLabel(0)
	end
	-- 向玩家显示选择提示，要求从墓地选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中的1张「宝石骑士」卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c45662855.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：效果处理时将使对象卡加入手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将之前选择的对象卡加入手牌，并向对手确认那张卡。
function c45662855.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果把对象卡送入持有者的手卡（加入手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的那张卡，使其透明可查看。
		Duel.ConfirmCards(1-tp,tc)
	end
end
