--ロイヤル・ペンギンズ・ガーデン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把「王家企鹅花园」以外的1张「企鹅」卡加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。从手卡以及自己场上的表侧表示怪兽之中选1只「企鹅」怪兽，那只怪兽的等级直到回合结束时下降1星。那之后，选自己1张手卡丢弃。
function c80893872.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把「王家企鹅花园」以外的1张「企鹅」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,80893872+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c80893872.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从手卡以及自己场上的表侧表示怪兽之中选1只「企鹅」怪兽，那只怪兽的等级直到回合结束时下降1星。那之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80893872,1))
	e2:SetCategory(CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c80893872.lvtg)
	e2:SetOperation(c80893872.lvop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「王家企鹅花园」以外且可以加入手牌的「企鹅」卡片
function c80893872.thfilter(c)
	return c:IsSetCard(0x5a) and not c:IsCode(80893872) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理：可以从卡组把1张「王家企鹅花园」以外的「企鹅」卡加入手卡
function c80893872.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足检索条件的「企鹅」卡片组
	local g=Duel.GetMatchingGroup(c80893872.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在可检索的卡，则询问玩家是否发动检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(80893872,0)) then  --"是否从卡组把「企鹅」卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤手牌中或场上表侧表示的、等级在2星以上且属于「企鹅」的怪兽
function c80893872.lvfilter(c)
	return c:IsSetCard(0x5a) and c:IsLevelAbove(2) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
-- 效果②的发动准备：检查是否存在可改变等级的「企鹅」怪兽以及手牌是否大于0，并设置丢弃手牌的操作信息
function c80893872.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在等级2以上且可以改变等级的「企鹅」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80893872.lvfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 检查玩家手牌数量是否大于0（用于后续的丢弃手牌处理）
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果②的效果处理：选择1只「企鹅」怪兽使其等级下降1星，之后丢弃1张手牌
function c80893872.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌及场上表侧表示的符合条件的「企鹅」怪兽
	local g=Duel.GetMatchingGroup(c80893872.lvfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要下降等级的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(80893872,2))  --"请选择要下降等级的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc:IsLocation(LOCATION_MZONE) then
			-- 若选择的是场上的怪兽，则在场上显式示出被选中的怪兽
			Duel.HintSelection(sg)
		else
			-- 若选择的是手牌中的怪兽，则向对方玩家确认该怪兽
			Duel.ConfirmCards(1-tp,sg)
			-- 确认手牌怪兽后，重新洗切手牌
			Duel.ShuffleHand(tp)
		end
		-- 那只怪兽的等级直到回合结束时下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
		-- 中断效果处理，使后续的丢弃手牌处理与等级下降不视为同时进行
		Duel.BreakEffect()
		-- 让玩家选择并丢弃1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)
	end
end
