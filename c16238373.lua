--大電脳兵廠
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只念动力族怪兽为对象，支付那个等级×200基本分才能发动。比那只怪兽等级高并持有相同属性的1只机械族怪兽从卡组加入手卡。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的念动力族怪兽和机械族怪兽各1只为对象才能发动。那之内的1只回到卡组最下面，另1只加入手卡。
local s,id,o=GetID()
-- 注册两个效果：①起动效果（支付LP检索机械族怪兽）和②发动效果（从墓地除外自身，选择除外的念动力族和机械族怪兽各1只，1只回到卡组底端，另1只加入手卡）
function s.initial_effect(c)
	-- ①：以自己场上1只念动力族怪兽为对象，支付那个等级×200基本分才能发动。比那只怪兽等级高并持有相同属性的1只机械族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的念动力族怪兽和机械族怪兽各1只为对象才能发动。那之内的1只回到卡组最下面，另1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收除外的卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 效果发动条件：这张卡在本回合没有送去墓地
	e2:SetCondition(aux.exccon)
	-- 效果发动费用：将这张卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动费用处理：设置标签为100，表示可以发动
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- ①效果的对象过滤器：对象必须是表侧表示的念动力族怪兽，且满足支付LP和检索机械族怪兽的条件
function s.cfilter(c,tp)
	-- ①效果的对象必须是表侧表示的念动力族怪兽
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and Duel.CheckLPCost(tp,c:GetLevel()*200)
		-- ①效果的对象必须满足能检索比其等级高且属性相同的机械族怪兽的条件
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetAttribute())
end
-- ①效果的检索过滤器：机械族怪兽，属性相同，等级高于目标怪兽，且能加入手牌
function s.thfilter(c,lv,att)
	return c:IsRace(RACE_MACHINE) and bit.band(c:GetAttribute(),att)~=0 and c:GetLevel()>lv and c:IsAbleToHand()
end
-- ①效果的发动处理：选择对象怪兽，支付其等级×200LP，检索满足条件的机械族怪兽加入手牌
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- ①效果的发动条件：场上存在满足条件的念动力族怪兽作为对象
		return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	e:SetLabel(0)
	-- ①效果的发动提示：提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- ①效果的对象选择：选择1只满足条件的念动力族怪兽作为对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- ①效果的发动费用：支付对象怪兽等级×200LP
	Duel.PayLPCost(tp,tc:GetLevel()*200)
	-- ①效果的发动信息设置：设置将要检索的机械族怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的发动处理：检索满足条件的机械族怪兽加入手牌并确认
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①效果的发动处理：获取选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- ①效果的发动提示：提示玩家选择要加入手牌的机械族怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- ①效果的发动处理：选择满足条件的机械族怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel(),tc:GetAttribute())
		if g:GetCount()>0 then
			-- ①效果的发动处理：将机械族怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- ①效果的发动处理：确认玩家手牌
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的对象过滤器：除外状态的念动力族或机械族怪兽，且能成为效果对象
function s.tdfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsAbleToHand(e,0,tp))
		and c:IsRace(RACE_MACHINE+RACE_PSYCHO)
end
-- ②效果的组合筛选器：选择的2张卡中必须有1张能回到卡组底端，1张能加入手牌，且分别属于念动力族和机械族
function s.fselect(g,e,tp)
	return g:IsExists(Card.IsAbleToDeck,1,nil) and g:IsExists(Card.IsAbleToHand,1,nil)
		and g:IsExists(Card.IsRace,1,nil,RACE_MACHINE) and g:IsExists(Card.IsRace,1,nil,RACE_PSYCHO)
end
-- ②效果的发动处理：选择2张满足条件的除外怪兽，设置为效果对象
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- ②效果的发动处理：获取所有满足条件的除外怪兽
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chkc then return false end
	if chk==0 then return dg:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- ②效果的发动提示：提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- ②效果的发动处理：设置效果对象卡组
	Duel.SetTargetCard(g)
	-- ②效果的发动信息设置：设置将要返回卡组底端的卡数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- ②效果的发动信息设置：设置将要加入手牌的卡数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的返回卡组底端的过滤器：能回到卡组底端的怪兽
function s.thfilter2(c,e,tp)
	return c:IsAbleToDeck()
end
-- ②效果的发动处理：选择1张卡返回卡组底端，其余卡加入手牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果的发动处理：获取当前连锁效果的对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- ②效果的发动提示：提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:FilterSelect(tp,s.thfilter2,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- ②效果的发动处理：显示选择的卡被选为对象
			Duel.HintSelection(sg)
			-- ②效果的发动处理：将卡放回卡组底端
			aux.PlaceCardsOnDeckBottom(tp,sg)
			tg:Sub(sg)
			if sg:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) and tg:GetCount()>0 and tg:GetFirst():IsAbleToHand() then
				-- ②效果的发动处理：将剩余卡加入手牌
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- ②效果的发动处理：确认玩家手牌
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end
