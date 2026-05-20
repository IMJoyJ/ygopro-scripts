--ハーピィ・ハーピスト
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：这张卡召唤时，以自己场上1只其他的鸟兽族怪兽和对方场上1只表侧表示怪兽为对象才能发动。那些怪兽回到手卡。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只攻击力1500以下的鸟兽族·4星怪兽加入手卡。
function c56585883.initial_effect(c)
	-- 使这张卡在场上·墓地存在时，卡名当作「鹰身女郎」使用。
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡召唤时，以自己场上1只其他的鸟兽族怪兽和对方场上1只表侧表示怪兽为对象才能发动。那些怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56585883,0))  --"弹回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,56585883)
	e2:SetTarget(c56585883.target)
	e2:SetOperation(c56585883.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只攻击力1500以下的鸟兽族·4星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c56585883.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只攻击力1500以下的鸟兽族·4星怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56585883,1))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,56585884)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c56585883.thcon)
	e4:SetTarget(c56585883.thtg)
	e4:SetOperation(c56585883.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的鸟兽族怪兽，且能回到手卡。
function c56585883.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 过滤条件：对方场上表侧表示且能回到手卡的怪兽。
function c56585883.filter2(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果②的发动准备与对象选择。
function c56585883.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在除这张卡以外的1只表侧表示鸟兽族怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c56585883.filter1,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 并且检查对方场上是否存在1只表侧表示怪兽作为可选对象。
		and Duel.IsExistingTarget(c56585883.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只其他的鸟兽族怪兽作为对象。
	local g1=Duel.SelectTarget(tp,c56585883.filter1,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象。
	local g2=Duel.SelectTarget(tp,c56585883.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁信息，表示将选中的2张卡送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果②的处理：将作为对象的怪兽送回手牌。
function c56585883.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些怪兽因效果送回持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 在被送去墓地时，给这张卡注册一个在本回合结束阶段前有效的Flag，用于标记其在本回合被送去过墓地。
function c56585883.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(56585883,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③的发动条件：检查这张卡在本回合是否被送去过墓地（是否存在对应的Flag）。
function c56585883.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(56585883)>0
end
-- 过滤条件：卡组中攻击力1500以下的4星鸟兽族怪兽，且能加入手牌。
function c56585883.thfilter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_WINDBEAST) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果③的发动准备：检查卡组中是否存在符合条件的怪兽，并设置检索的操作信息。
function c56585883.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c56585883.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果将从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理：从卡组选择1只符合条件的怪兽加入手牌并给对方确认。
function c56585883.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c56585883.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
