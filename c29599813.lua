--ピュアリィ・プリティメモリー
-- 效果：
-- ①：双方回复1000基本分。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：有这张卡在作为超量素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●1回合1次，把自己场上1张其他卡送去墓地，以对方场上1张卡为对象才能发动。那张卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化卡片效果，注册双方回血并可弃手卡从卡组特召的①效果，以及作为「纯爱妖精」超量怪兽素材时赋予的②效果
function s.initial_effect(c)
	-- ①：双方回复1000基本分。并且，可以再让以下效果适用。 ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：有这张卡在作为超量素材中的「纯爱妖精」超量怪兽得到以下效果。 ●1回合1次，把自己场上1张其他卡送去墓地，以对方场上1张卡为对象才能发动。那张卡作为这张卡的超量素材。
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
-- 发动条件检查，设置使双方玩家各回复1000基本分的操作信息
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使双方玩家各自回复1000基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
-- 过滤函数，检查是否为卡组中1星「纯爱妖精」且可特殊召唤的怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理，双方各回复1000基本分，之后在满足手卡丢弃与特召条件时可丢弃1张手卡并从卡组特殊召唤1只1星「纯爱妖精」怪兽
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己与对方各自依效果回复1000基本分并判断是否均成功回复
	if Duel.Recover(tp,1000,REASON_EFFECT)>0 and Duel.Recover(1-tp,1000,REASON_EFFECT)>0
		-- 检查自己手卡是否存在至少1张可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		-- 检查自己怪兽区是否至少有1个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只可特殊召唤的1星「纯爱妖精」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问控制者是否再适用丢弃手卡并从卡组特殊召唤怪兽的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
		-- 中断当前效果处理，使后续弃手卡与特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 让控制者选择并依效果丢弃1张手卡，并判断丢弃是否成功
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			-- 提示控制者从卡组选择要特殊召唤的1星「纯爱妖精」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己卡组选择1只1星「纯爱妖精」怪兽
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的1星「纯爱妖精」怪兽表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 发动条件检查，确认持有此赋予效果的超量怪兽属于「纯爱妖精」字段
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x18c)
end
-- 发动代价处理，检查并选择把自己场上除自身外的1张卡送去墓地
function s.xcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在这张超量怪兽以外至少1张可作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示控制者选择自己场上要作为代价送去墓地的其他卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张除这张超量怪兽以外可送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的自己场上其他卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检查对方场上是否存在可作为超量素材的卡，并在持续检验时确认对象合法性
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsCanOverlay() end
	-- 检查对方场上是否存在至少1张能成为对象并作为超量素材的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方提示发动的赋予效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示控制者选择对方场上要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择对方场上1张可作为超量素材的卡作为本次连锁的对象
	Duel.SelectTarget(tp,Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理，确认双方卡片均与效果关联且目标不受免疫后，清理目标原有超量素材并将其叠放为这张卡的超量素材
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象选择的对方场上的卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		tc:CancelToGrave()
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 若目标卡自身持有超量素材，按规则把其原本的超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标卡叠放到这张超量怪兽下方作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
