--劫火の眠り姫 ゴースト・スリーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把1张「幽合-幽鬼融合」加入手卡。
-- ②：把墓地的这张卡除外，丢弃1张手卡，以除外的1只自己的4星以上的不死族怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c99370594.initial_effect(c)
	-- 将卡号35705817（幽合-幽鬼融合）记录为这张卡代码列表中记载的卡名，以便进行相关检索/字段判定。
	aux.AddCodeList(c,35705817)
	-- ①：这张卡被送去墓地的场合才能发动。从卡组把1张「幽合-幽鬼融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99370594,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,99370594)
	e1:SetTarget(c99370594.thtg)
	e1:SetOperation(c99370594.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，丢弃1张手卡，以除外的1只自己的4星以上的不死族怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99370594,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动（若因返回手牌等特殊除外场合除外则不受限）。
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,99370595)
	e2:SetCost(c99370594.thcost)
	e2:SetTarget(c99370594.target1)
	e2:SetOperation(c99370594.activate1)
	c:RegisterEffect(e2)
end
-- 定义①效果的过滤器：检索的对象必须是卡号35705817的「幽合-幽鬼融合」，且该卡能够加入手牌。
function c99370594.thfilter(c)
	return c:IsCode(35705817) and c:IsAbleToHand()
end
-- ①效果的目标/发动合法性函数：确认卡组存在符合条件的检索对象，并声明本次效果为回手牌检索。
function c99370594.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认卡组中至少有1张符合条件的「幽合-幽鬼融合」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c99370594.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果涉及从卡组将1张卡加入手牌（CATEGORY_TOHAND），用于后续处理及连锁发动的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时：从卡组选择1张「幽合-幽鬼融合」加入手牌，并向对方确认加入手牌的卡。
function c99370594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字“请选择要加入手牌的卡”，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张符合条件的「幽合-幽鬼融合」。
	local g=Duel.SelectMatchingCard(tp,c99370594.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「幽合-幽鬼融合」加入其持有者的手牌，处理原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把刚加入手牌的「幽合-幽鬼融合」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的代价函数：检查墓地中的这张卡能否除外以及手牌中是否有可丢弃的卡，以满足两个代价条件。
function c99370594.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 代价检查的另一部分：确认手牌中至少存在1张可以被丢弃的卡（满足丢弃条件）。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地中的这张卡以正面表示除外，作为发动②效果的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手牌丢弃1张卡，作为发动②效果的代价（丢弃行为本身也属于丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义②效果的对象过滤器：选择除外区中自己控制的、正面表示的、4星以上的不死族怪兽，且该怪兽能够加入手牌。
function c99370594.filter0(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(4) and c:IsAbleToHand() and c:IsFaceup()
end
-- ②效果的目标处理函数：从除外区选择1只符合条件的自己的不死族怪兽作为对象，并设置回手牌的操作信息。
function c99370594.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c99370594.filter0(chkc) end
	-- 检查是否存在满足条件的取对象目标，若没有则不能发动②效果。
	if chk==0 then return Duel.IsExistingTarget(c99370594.filter0,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示选择提示文字“请选择要加入手牌的卡”，引导玩家进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1只符合条件的自己的不死族怪兽，并将其设为当前效果的对象。
	local g=Duel.SelectTarget(tp,c99370594.filter0,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将确定的对象卡加入手牌（CATEGORY_TOHAND），供后续效果处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理时：将之前选择的不死族怪兽加入手牌。
function c99370594.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果所选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者手牌，处理原因是效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
