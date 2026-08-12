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
-- 过滤满足条件的卡片：通过融合送入墓地的怪兽，且可以送去手卡，且可以成为效果对象
function c44072894.filter(c,e)
	return c:IsReason(REASON_FUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 效果处理时选择目标：从自己墓地选择满足条件的2只怪兽作为效果对象
function c44072894.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44072894.filter(chkc,e) end
	if chk==0 then return true end
	-- 检索满足条件的卡片组：从自己墓地检索通过融合送入墓地的怪兽
	local g=Duel.GetMatchingGroup(c44072894.filter,tp,LOCATION_GRAVE,0,nil,e)
	if g:GetCount()>=2 then
		-- 向玩家提示选择卡片：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 设置当前效果的目标卡片：将选中的2只怪兽设置为效果对象
		Duel.SetTargetCard(sg)
		-- 设置效果操作信息：设置将2只怪兽送入手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,2,0,0)
	end
end
-- 效果处理：将符合条件的2只怪兽送入手卡并确认对方查看
function c44072894.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将目标怪兽送去手卡：以效果原因将怪兽送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手卡的怪兽：向对方玩家展示送入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
