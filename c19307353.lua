--魂の造形家
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。把1只原本攻击力和原本守备力的合计是和解放的怪兽相同的怪兽从卡组加入手卡。
function c19307353.initial_effect(c)
	-- 创建效果1，设置效果描述、分类、类型、适用区域、使用次数限制、费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19307353,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19307353)
	e1:SetCost(c19307353.thcost)
	e1:SetTarget(c19307353.thtg)
	e1:SetOperation(c19307353.thop)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在可解放的怪兽，且该怪兽的攻击力与守备力之和在卡组中存在匹配的怪兽
function c19307353.cfilter(c,tp)
	local sum=math.max(c:GetTextAttack(),0)+math.max(c:GetTextDefense(),0)
	return c:IsAttackAbove(0) and c:IsDefenseAbove(0)
		-- 检查卡组中是否存在攻击力与守备力之和等于指定值的怪兽
		and Duel.IsExistingMatchingCard(c19307353.thfilter,tp,LOCATION_DECK,0,1,nil,sum)
end
-- 筛选卡组中攻击力与守备力之和等于指定值的怪兽，且该怪兽为怪兽卡并能加入手牌
function c19307353.thfilter(c,csum)
	local sum=math.max(c:GetTextAttack(),0)+math.max(c:GetTextDefense(),0)
	return c:IsAttackAbove(0) and c:IsDefenseAbove(0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and csum==sum
end
-- 支付效果费用，解放场上一只符合条件的怪兽，并记录其攻击力与守备力之和
function c19307353.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足支付费用的条件，即场上是否存在符合条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19307353.cfilter,1,nil,tp) end
	-- 选择场上一只符合条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c19307353.cfilter,1,1,nil,tp)
	local sum=math.max(g:GetFirst():GetTextAttack(),0)+math.max(g:GetFirst():GetTextDefense(),0)
	e:SetLabel(sum)
	-- 将选中的怪兽从场上解放，作为效果的费用
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理时的操作信息，确定将要从卡组检索的卡牌数量和位置
function c19307353.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，从卡组选择符合条件的怪兽加入手牌并确认对方查看
function c19307353.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择攻击力与守备力之和等于指定值的怪兽
	local g=Duel.SelectMatchingCard(tp,c19307353.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
