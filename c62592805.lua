--エピュアリィ・ノアール
-- 效果：
-- 2星怪兽×2
-- ①：1回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动（这张卡有「纯爱妖精瞌睡回忆」在作为超量素材的场合，对象可以变成2张）。那张卡回到手卡。
-- ②：1回合最多3次，自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡作为这张卡的超量素材。那之后，可以从卡组把1张「纯爱妖精」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化函数：注册卡片效果，包括超量召唤手续、①效果（起动效果，弹回对方场上的卡）和②效果（诱发即时效果，将发动的速攻魔法叠放为素材并盖放陷阱卡）
function s.initial_effect(c)
	-- 将「纯爱妖精瞌睡回忆」的卡片密码（21347668）加入该卡的关联卡片列表中
	aux.AddCodeList(c,21347668)
	-- 添加超量召唤手续：2星怪兽×2
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，丢弃1张手卡，以对方场上1张卡为对象才能发动（这张卡有「纯爱妖精瞌睡回忆」在作为超量素材的场合，对象可以变成2张）。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方卡回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：1回合最多3次，自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡作为这张卡的超量素材。那之后，可以从卡组把1张「纯爱妖精」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动的速攻魔法卡在这张卡下面重叠"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价（Cost）函数：丢弃1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以丢弃和代价为原因将1张手卡送去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动准备（Target）函数：选择对方场上的卡作为对象，若有「纯爱妖精瞌睡回忆」作为素材则可选最多2张
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在至少1张可以返回手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local ct=e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,21347668) and 2 or 1
	-- 在自己屏幕上显示“请选择要返回手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张（若有特定素材则最多2张）可以返回手卡的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息，表明此效果包含将选中的卡送回手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ①效果的处理（Operation）函数：将作为对象的卡送回持有者手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在当前连锁处理时仍然符合对象关系的卡片集合
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 以效果原因为原因将目标卡片送回持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件（Condition）函数：自己发动了「纯爱妖精」速攻魔法卡的效果
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
		and re:IsActiveType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x18c)
end
-- ②效果的发动准备（Target）函数：检查发动的魔法卡是否能作为超量素材，并建立效果联系
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end
-- ②效果的处理（Operation）函数：将发动的速攻魔法卡作为这张卡的超量素材，之后可从卡组盖放1张「纯爱妖精」陷阱卡
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		-- 检查是否成功将魔法卡重叠为素材，且卡组中是否存在可盖放的「纯爱妖精」陷阱卡
		if Duel.Overlay(c,tc)~=0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否选择从卡组把陷阱卡在自己场上盖放
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组把陷阱卡在自己场上盖放？"
			-- 中断当前效果处理，使后续的盖放操作与之前的重叠素材操作不视为同时处理
			Duel.BreakEffect()
			-- 在自己屏幕上显示“请选择要盖放的卡”的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从卡组中选择1张满足条件的「纯爱妖精」陷阱卡
			local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的陷阱卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 过滤函数：筛选卡组中属于「纯爱妖精」系列的、可以盖放的陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
