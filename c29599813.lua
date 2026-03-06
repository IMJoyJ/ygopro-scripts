--ピュアリィ・プリティメモリー
-- 效果：
-- ①：双方回复1000基本分。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：有这张卡在作为超量素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●1回合1次，把自己场上1张其他卡送去墓地，以对方场上1张卡为对象才能发动。那张卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：双方回复1000基本分。并且，可以再让以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：有这张卡在作为超量素材中的「纯爱妖精」超量怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"补充超量素材（纯爱妖精可爱回忆）"
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.xcon)
	e2:SetCost(s.xcost)
	e2:SetTarget(s.xtg)
	e2:SetOperation(s.xop)
	c:RegisterEffect(e2)
end
-- 设置①效果的处理目标为双方回复1000基本分
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为双方回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
-- 定义过滤函数，用于筛选1星纯爱妖精怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理函数，执行双方回复1000基本分并询问是否特殊召唤
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 双方回复1000基本分
	if Duel.Recover(tp,1000,REASON_EFFECT)>0 and Duel.Recover(1-tp,1000,REASON_EFFECT)>0
		-- 确认玩家手牌中有可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		-- 确认玩家场上存在可用怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家卡组中存在1星纯爱妖精怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否发动特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 丢弃1张手卡
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择1只1星纯爱妖精怪兽
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽特殊召唤到场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- ②效果的发动条件，确认该卡为纯爱妖精族
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x18c)
end
-- ②效果的费用支付函数，将场上1张卡送去墓地
function s.xcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可作为费用的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张可送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标选择函数，选择对方场上的卡作为超量素材
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsCanOverlay() end
	-- 检查是否存在可作为超量素材的目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择对方场上的1张卡作为超量素材
	Duel.SelectTarget(tp,Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果的处理函数，将目标卡叠放至自身
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		tc:CancelToGrave()
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标卡的叠放卡送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标卡叠放至自身
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
