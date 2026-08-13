--閃刀空域－エリアゼロ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以这张卡以外的自己场上1张卡为对象才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「闪刀」卡加入手卡。剩下的卡回到卡组。「闪刀」卡被翻开的场合，再把作为对象的卡送去墓地。
-- ②：这张卡被效果从场地区域送去墓地的场合才能发动。从卡组把1只「闪刀姬」怪兽特殊召唤。
function c50005218.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以这张卡以外的自己场上1张卡为对象才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「闪刀」卡加入手卡。剩下的卡回到卡组。「闪刀」卡被翻开的场合，再把作为对象的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50005218,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,50005218)
	e2:SetTarget(c50005218.thtg)
	e2:SetOperation(c50005218.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果从场地区域送去墓地的场合才能发动。从卡组把1只「闪刀姬」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50005218,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,50005219)
	e3:SetCondition(c50005218.spcon)
	e3:SetTarget(c50005218.sptg)
	e3:SetOperation(c50005218.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果的发动目标函数：获取效果持有者，若为连锁选择对象则校验对象是场上且自己控制且不是这张卡；在发动合法性检查时，要求自己场上有这张卡以外的卡可选且卡组至少3张。
function c50005218.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 在发动合法性检查时，判断自己场上是否存在至少1张除本卡以外的卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c)
		-- 同时判断自己卡组最上方是否有至少3张卡，确保可以翻开3张。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 向操作玩家显示“请选择要送去墓地的卡”的提示，用于选择对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张除本卡以外的卡作为效果对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置操作信息，声明本效果包含从卡组把1张卡加入手卡的检索处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
	-- 设置操作信息，声明本效果可能将作为对象的卡送去墓地，并记录对象卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 定义「闪刀」卡检索过滤器：卡属于「闪刀」系列且能够加入手卡。
function c50005218.thfilter(c)
	return c:IsSetCard(0x115) and c:IsAbleToHand()
end
-- ①效果的解决函数：确认卡组顶3张；若其中有「闪刀」卡则询问是否选1张加入手卡；加入后展示并洗切手卡；若对象仍与效果相关则将对象送去墓地；最后洗切卡组。
function c50005218.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡（取对象的目标）。
	local tc=Duel.GetFirstTarget()
	-- 确认（展示）自己卡组最上方3张卡给双方。
	Duel.ConfirmDecktop(tp,3)
	-- 获取自己卡组最上方3张卡作为一组，用于后续筛选。
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		if g:IsExists(Card.IsSetCard,1,nil,0x115) then
			-- 如果翻开的卡中存在可加入手卡的「闪刀」卡，则询问玩家是否选择1张加入手卡。
			if g:IsExists(c50005218.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(50005218,2)) then  --"是否选卡加入手卡？"
				-- 显示“请选择要加入手牌的卡”的提示，用于选择要加入手卡的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:FilterSelect(tp,c50005218.thfilter,1,1,nil)
				-- 将选择的卡以效果理由加入其持有者的手卡。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 将刚加入手卡的卡展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切自己的手卡（防止对手知道检索到的卡是具体哪一张）。
				Duel.ShuffleHand(tp)
			end
			if tc:IsRelateToEffect(e) then
				-- 如果作为对象的卡仍然与效果相关，则将该卡以效果理由送去墓地。
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
		-- 洗切自己的卡组（因为翻开了卡组并可能改变了卡组顺序）。
		Duel.ShuffleDeck(tp)
	end
end
-- 定义②效果的发动条件：这张卡因效果送去墓地，且离场前处于场地区域。
function c50005218.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
-- 定义「闪刀姬」怪兽的筛选条件：属于「闪刀姬」系列且能够被当前效果特殊召唤。
function c50005218.spfilter(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性检查：自己主要怪兽区有空位，且卡组中存在符合条件的「闪刀姬」怪兽。
function c50005218.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空格，以确定能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「闪刀姬」怪兽。
		and Duel.IsExistingMatchingCard(c50005218.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明本效果将从卡组特殊召唤1只怪兽，用于连锁/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的解决函数：若主要怪兽区有空位，则从卡组选择1只符合条件的「闪刀姬」怪兽，以表侧表示特殊召唤。
function c50005218.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位；若没有空位，则效果处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，用于选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1张满足条件的「闪刀姬」怪兽。
	local g=Duel.SelectMatchingCard(tp,c50005218.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件、无视苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
