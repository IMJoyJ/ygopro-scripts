--魔轟神マルコシア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。从手卡选包含「魔轰神」怪兽在内的最多2只「魔轰神 马可西亚」以外的怪兽丢弃，这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升这个效果丢弃的怪兽数量×200。
-- ②：这张卡从手卡丢弃去墓地的场合发动。从卡组把1张「魔轰神」魔法·陷阱卡加入手卡。
function c57630503.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从手卡选包含「魔轰神」怪兽在内的最多2只「魔轰神 马可西亚」以外的怪兽丢弃，这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升这个效果丢弃的怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57630503,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,57630503)
	e1:SetTarget(c57630503.tg)
	e1:SetOperation(c57630503.op)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃去墓地的场合发动。从卡组把1张「魔轰神」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57630503,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,57630504)
	e2:SetCondition(c57630503.thcon)
	e2:SetTarget(c57630503.thtg)
	e2:SetOperation(c57630503.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除「魔轰神 马可西亚」以外的「魔轰神」怪兽且可以丢弃的怪兽卡
function c57630503.dhfilter(c)
	return not c:IsCode(57630503) and c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 过滤手卡中除「魔轰神 马可西亚」以外的可以丢弃的怪兽卡
function c57630503.dhfilter1(c)
	return not c:IsCode(57630503) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 检查选中的卡片组中是否包含至少1张「魔轰神」怪兽
function c57630503.gselect(g)
	return g:IsExists(c57630503.dhfilter,1,nil)
end
-- ①号效果的发动准备与合法性检测
function c57630503.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张除自身以外的「魔轰神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57630503.dhfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查自身是否能特殊召唤，且己方场上有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，预估将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①号效果的处理：丢弃手卡怪兽，特殊召唤自身并上升攻击力
function c57630503.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡中除自身以外的所有「魔轰神」怪兽
	local g=Duel.GetMatchingGroup(c57630503.dhfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 获取手卡中除自身以外的所有怪兽
	local hg=Duel.GetMatchingGroup(c57630503.dhfilter1,tp,LOCATION_HAND,0,e:GetHandler())
	if #g<1 then return end
	if #g==1 and #hg==0 then
		-- 当手卡中只有1张符合条件的「魔轰神」怪兽且没有其他怪兽时，直接丢弃该「魔轰神」怪兽
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local tg=hg:SelectSubGroup(tp,c57630503.gselect,false,1,2)
		-- 将玩家选择的1到2张手卡怪兽丢弃送去墓地
		Duel.SendtoGrave(tg,REASON_DISCARD+REASON_EFFECT)
	end
	-- 获取实际被丢弃送去墓地的卡片组以及自身卡片对象
	local og,c=Duel.GetOperatedGroup(),e:GetHandler()
	-- 如果自身仍存在于手卡且成功特殊召唤，并且有卡片被成功丢弃，则进行攻击力上升的处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and #og>0 then
		-- 这个效果特殊召唤的这张卡的攻击力上升这个效果丢弃的怪兽数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(#og*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 检查此卡是否是从手卡被丢弃去墓地
function c57630503.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 过滤卡组中的「魔轰神」魔法·陷阱卡
function c57630503.thfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②号效果的发动准备，设置检索卡片的操作信息
function c57630503.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置加入手卡的操作信息，预估从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理：从卡组将1张「魔轰神」魔法·陷阱卡加入手卡
function c57630503.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「魔轰神」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c57630503.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
