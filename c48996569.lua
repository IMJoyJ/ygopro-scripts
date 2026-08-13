--E・HERO グラン・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·大地鼹鼠」
-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」魔法卡）。1回合1次，可以选择对方场上1只怪兽回到持有者手卡。此外，结束阶段时，这张卡回到额外卡组。
function c48996569.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以“元素英雄 新宇侠”（89943723）和“新空间侠·大地鼹鼠”（80344569）为素材的融合召唤手续，使其满足正规出场条件。
	aux.AddFusionProcCode2(c,89943723,80344569,false,false)
	-- 注册接触融合特殊召唤手续：将己方场上满足条件的上述素材卡作为Cost返回卡组·额外卡组，然后从额外卡组特殊召唤这张卡；素材处理采用默认的回卡组并洗牌的操作。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 「元素英雄 新宇侠」＋「新空间侠·大地鼹鼠」让自己场上的上记的卡回到卡组·额外卡组的场合才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c48996569.splimit)
	c:RegisterEffect(e1)
	-- 注册“新空间”融合怪兽共通效果：在自己·对方的结束阶段时，这张卡回到额外卡组，并执行retop作为回额外卡组的具体处理。
	aux.EnableNeosReturn(c,c48996569.retop)
	-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽回到手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(48996569,1))  --"返回手牌"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(c48996569.thtg)
	e5:SetOperation(c48996569.thop)
	c:RegisterEffect(e5)
end
c48996569.material_setcode=0x8
-- 特殊召唤限制的判定函数：仅允许从额外卡组进行的特殊召唤，禁止从墓地、除外或手卡等额外卡组以外的区域特殊召唤这张卡。
function c48996569.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段回额外卡组的处理函数：若这张卡仍与效果关联且不是里侧表示，则将其返回卡组（融合怪兽实际回到额外卡组）并洗牌。
function c48996569.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将这张卡以效果原因送回持有者卡组并洗牌；作为额外卡组怪兽，实际处理为回到持有者的额外卡组。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 回手牌效果的过滤函数：判断卡片是否能被送回手牌，即不受“不能加入手卡”等效果限制。
function c48996569.filter(c)
	return c:IsAbleToHand()
end
-- ①效果的发动条件与取对象处理：选择对方场上1只符合回手牌条件的怪兽，并设置本次操作信息为回手牌效果。
function c48996569.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c48996569.filter(chkc) end
	-- 在效果发动合法性检查时，确认对方场上是否存在至少1只满足回手牌条件的怪兽，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c48996569.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发出选择提示，提示内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1只满足回手牌条件的怪兽，并将其设为当前连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c48996569.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将选中的对象标记为回手牌（CATEGORY_TOHAND），以便后续处理及相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的操作：取出对象怪兽，若其仍与效果关联，则将其返回持有者手卡，实现“那只对方怪兽回到手卡”。
function c48996569.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所登记的第一个效果对象，也就是之前选择的那只对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽返回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
