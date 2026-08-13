--魂の造形家
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。把1只原本攻击力和原本守备力的合计是和解放的怪兽相同的怪兽从卡组加入手卡。
function c19307353.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上1只怪兽解放才能发动。把1只原本攻击力和原本守备力的合计是和解放的怪兽相同的怪兽从卡组加入手卡。
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
-- 解放代价的筛选函数：计算候选怪兽的原本攻防合计，并检查卡组中是否存在该合计的可检索怪兽。
function c19307353.cfilter(c,tp)
	local sum=math.max(c:GetTextAttack(),0)+math.max(c:GetTextDefense(),0)
	return c:IsAttackAbove(0) and c:IsDefenseAbove(0)
		-- 检查卡组中是否存在1张原本攻防合计等于候选怪兽合计、且满足检索条件的怪兽卡。
		and Duel.IsExistingMatchingCard(c19307353.thfilter,tp,LOCATION_DECK,0,1,nil,sum)
end
-- 检索筛选函数：判断卡组中的怪兽是否原本攻防合计等于指定数值、且可加入手卡。
function c19307353.thfilter(c,csum)
	local sum=math.max(c:GetTextAttack(),0)+math.max(c:GetTextDefense(),0)
	return c:IsAttackAbove(0) and c:IsDefenseAbove(0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and csum==sum
end
-- 代价函数：从己方场上选择并解放1只满足条件的怪兽，将其原本攻防合计记录到效果标签，供效果处理时检索使用。
function c19307353.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：检查是否至少存在1只满足条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19307353.cfilter,1,nil,tp) end
	-- 选择1只满足条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c19307353.cfilter,1,1,nil,tp)
	local sum=math.max(g:GetFirst():GetTextAttack(),0)+math.max(g:GetFirst():GetTextDefense(),0)
	e:SetLabel(sum)
	-- 将选择的怪兽解放作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果发动目标的判定：允许发动，并注册将要从卡组加入手牌的操作信息。
function c19307353.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果将进行“从卡组将1张卡加入手牌”的操作信息，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽加入手牌，并向对方展示。
function c19307353.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只原本攻防合计等于记录值且可加入手牌的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19307353.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
