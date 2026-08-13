--花積み
-- 效果：
-- 「花积」的②的效果1回合只能使用1次。
-- ①：从卡组选「花札卫」怪兽3种类，用喜欢的顺序回到卡组上面。
-- ②：把墓地的这张卡除外，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c30786387.initial_effect(c)
	-- ①：从卡组选「花札卫」怪兽3种类，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30786387,0))  --"卡片顺序"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30786387.target)
	e1:SetOperation(c30786387.activate)
	c:RegisterEffect(e1)
	-- 「花积」的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30786387,2))  --"卡片回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30786387)
	-- 设置②效果的发动条件：本回合若是此卡送去墓地的回合则不能发动（aux.exccon实现“送去墓地的回合不能发动”的限制）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动COST：将此卡从墓地除外（aux.bfgcost实现除外自身的cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30786387.thtg)
	e2:SetOperation(c30786387.thop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：卡为「花札卫」系列（setcode 0xe6）的怪兽卡，用于检索/选取符合条件的卡。
function c30786387.filter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动条件判定：检查我方卡组中是否存在至少3种不同卡名的「花札卫」怪兽（通过GetClassCount(Card.GetCode)统计不同卡名数量）。
function c30786387.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取我方卡组中所有满足filter条件的「花札卫」怪兽组成的集合，用于后续选择。
		local g=Duel.GetMatchingGroup(c30786387.filter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
end
-- ①效果处理：若卡组中仍有至少3种不同卡名的花札卫怪兽，则提示玩家选择3张卡名互不相同的「花札卫」怪兽；向对方展示后洗切卡组，将所选卡放到卡组最上方，最后由玩家按喜好排列顺序。
function c30786387.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足filter条件的「花札卫」怪兽组成的集合，用于①效果处理。
	local g=Duel.GetMatchingGroup(c30786387.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 给玩家tp显示选择提示（提示文本为“请选择要放到卡组上面的卡”），用于选择要放置到卡组顶部的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30786387,1))  --"请选择要放到卡组上面的卡"
		-- 让玩家从卡组集合g中选择3张卡名互不相同的「花札卫」怪兽（aux.dncheck保证卡名不同），作为要放在卡组上面的卡，不能取消。
		local rg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选中的3张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,rg)
		-- 洗切我方卡组，为将选中的卡按喜好顺序放置到卡组顶部做准备。
		Duel.ShuffleDeck(tp)
		local tg=rg:GetFirst()
		while tg do
			-- 将当前选中的卡片移动到卡组最上方；循环后所选卡都被移到顶部，随后用SortDecktop调整顺序。
			Duel.MoveSequence(tg,SEQ_DECKTOP)
			tg=rg:GetNext()
		end
		-- 让玩家tp对我方卡组最上方3张卡进行排序，从而实现“用喜欢的顺序回到卡组上面”。
		Duel.SortDecktop(tp,tp,3)
	end
end
-- 定义②效果的对象条件：是「花札卫」系列怪兽且可以被加入手卡。
function c30786387.thfilter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标设定：确认对象合法性后，提示玩家从自己墓地选择1只满足条件的「花札卫」怪兽作为对象，并设置操作信息为“加入手卡”。
function c30786387.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30786387.thfilter(chkc) end
	-- 发动条件判定：我方墓地是否存在1张以上满足thfilter条件的「花札卫」怪兽（即存在可回收的对象）。
	if chk==0 then return Duel.IsExistingTarget(c30786387.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片（HINTMSG_ATOHAND为选择加入手牌对象的通用提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的「花札卫」怪兽，并将其登记为当前连锁的效果对象。
	local sg=Duel.SelectTarget(tp,c30786387.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果类别为加入手卡（CATEGORY_TOHAND），处理对象为sg，数量为1，供系统进行相关检测和判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- ②效果处理：取得效果对象；若对象仍与此效果关联（未被移动或离场），则将其加入持有者手卡。
function c30786387.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的处理对象（即②效果选择的墓地1只「花札卫」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者的手卡，移动原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
