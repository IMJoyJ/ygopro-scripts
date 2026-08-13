--物資調達員
-- 效果：
-- 反转：通过「融合」而送去自己的墓地的2只融合素材怪兽加入手卡。
function c44072894.initial_effect(c)
	-- 反转：通过「融合」而送去自己的墓地的2只融合素材怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44072894,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c44072894.target)
	e1:SetOperation(c44072894.operation)
	c:RegisterEffect(e1)
end
-- 过滤出因「融合」而送去自己墓地、可成为效果对象且能够加入手卡的怪兽卡（融合素材怪兽）。
function c44072894.filter(c,e)
	return c:IsReason(REASON_FUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 目标选择函数：若指定候选卡则验证其为墓地且属于己方并符合过滤条件；发动检查时允许发动；处理时检索自己墓地符合条件的怪兽，若不少于2张则提示玩家选择2张，设置对象并登记加入手牌的操作信息。
function c44072894.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44072894.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取自己墓地中全部满足过滤条件（因融合送去墓地、怪兽、可加入手卡、可成为效果对象）的卡片集合。
	local g=Duel.GetMatchingGroup(c44072894.filter,tp,LOCATION_GRAVE,0,nil,e)
	if g:GetCount()>=2 then
		-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将玩家选择的2张墓地怪兽卡设置为当前连锁的效果对象，并使其与效果建立关联。
		Duel.SetTargetCard(sg)
		-- 登记操作信息：本连锁将把2张对象卡加入手牌（CATEGORY_TOHAND），供效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,2,0,0)
	end
end
-- 效果处理函数：取出发动时记录的目标卡，过滤出仍与该效果相关的卡；若仍有2张，则将其加入持有者手牌并向对方展示。
function c44072894.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理中记录的目标卡组（即发动时选择的2张融合素材怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将这些目标卡加入其持有者的手卡，处理原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片，以确认回收的融合素材怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
