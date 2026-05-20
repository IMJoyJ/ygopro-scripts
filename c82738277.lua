--ランカの蟲惑魔
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只「虫惑魔」怪兽加入手卡。
-- ②：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ③：1回合1次，以自己场上盖放的1张魔法·陷阱卡为对象才能发动。盖放的那张卡回到持有者手卡。那之后，可以从手卡把1张魔法·陷阱卡盖放。这个效果在对方回合也能发动。
function c82738277.initial_effect(c)
	-- ②：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c82738277.efilter)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只「虫惑魔」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82738277,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c82738277.thtg)
	e2:SetOperation(c82738277.thop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以自己场上盖放的1张魔法·陷阱卡为对象才能发动。盖放的那张卡回到持有者手卡。那之后，可以从手卡把1张魔法·陷阱卡盖放。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82738277,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetTarget(c82738277.rettg)
	e3:SetOperation(c82738277.retop)
	c:RegisterEffect(e3)
end
-- 不受「洞」或「落穴」通常陷阱卡效果影响的免疫效果过滤函数
function c82738277.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 检索「虫惑魔」怪兽的过滤条件函数
function c82738277.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x108a) and c:IsAbleToHand()
end
-- 效果①的发动准备（检查卡组是否存在可检索怪兽并设置操作信息）
function c82738277.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「虫惑魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82738277.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（从卡组将1只「虫惑魔」怪兽加入手卡并给对方确认）
function c82738277.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「虫惑魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c82738277.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上盖放的且能回到手卡的卡片
function c82738277.retfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 效果③的发动准备（选择自己场上盖放的1张魔陷作为对象，并设置操作信息）
function c82738277.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c82738277.retfilter(chkc) end
	-- 检查自己场上是否存在可以回到手卡的盖放的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c82738277.retfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上盖放的1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c82738277.retfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 设置操作信息为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理（对象卡回到手卡，之后可以从手卡盖放1张魔陷）
function c82738277.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown()
		-- 判定对象卡片是否成功回到手卡
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取手卡中可以盖放的魔法·陷阱卡组
		local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 若手卡有可盖放的卡，询问玩家是否进行盖放
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(82738277,2)) then  --"是否把魔法·陷阱卡盖放？"
			-- 洗切玩家的手卡
			Duel.ShuffleHand(tp)
			-- 中断当前效果，使之后的效果处理（盖放）不与回手牌同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
