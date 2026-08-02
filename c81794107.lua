--R.B.ラムダキャノン
-- 效果：
-- 这张卡召唤·特殊召唤的场合：可以以「奏悦机组 λ羔羊炮」以外的自己墓地1只「奏悦机组」怪兽为对象；那只怪兽加入手卡。
-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1200基本分；这张卡破坏，把对方的手卡确认，那之后可以把其中1只怪兽在对方场上效果无效特殊召唤。
-- 「奏悦机组 λ羔羊炮」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册召唤·特殊召唤时的选发检索和回收效果，以及在同系列连接怪兽连接区存在时的起动效果
function s.initial_effect(c)
	-- 这张卡召唤·特殊召唤的场合：可以以「奏悦机组 λ羔羊炮」以外的自己墓地1只「奏悦机组」怪兽为对象；那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1200基本分；这张卡破坏，把对方的手卡确认，那之后可以把其中1只怪兽在对方场上效果无效特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：同名卡以外的「奏悦机组」怪兽，并且能够加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检查墓地是否有满足条件的怪兽，提示玩家选择1个目标，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以加入手卡的「奏悦机组」怪兽目标
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设定操作信息：将选中的对象怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
-- 获取目标怪兽，检查其是否满足条件及不受王家长眠之谷影响，将其加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所选择的唯一对象卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否与当前连锁关联，且不受王家长眠之谷效果的阻挡
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽作为效果处理加入玩家手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：表侧表示的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 获取场上所有「奏悦机组」连接怪兽的连接区，检查这张卡是否处于那些连接区中
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的表侧表示的「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历获取到的所有「奏悦机组」连接怪兽
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 检查玩家是否能支付1200基本分，并支付这1200基本分作为代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1200基本分
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 让玩家支付1200基本分
	Duel.PayLPCost(tp,1200)
end
-- 检查对方是否有未公开的手卡，并设定将这张卡破坏的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在至少1张未公开的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
	-- 设定操作信息：将这张卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 过滤条件：能够往对方场上表侧表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 破坏自身后，确认对方手卡，若符合条件则可选对方手卡1只怪兽效果无效并特殊召唤到对方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否关联连锁，若未被破坏成功则终止后续处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取对方手卡的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 向我方玩家公开对方的手卡内容
		Duel.ConfirmCards(tp,g)
		if g:IsExists(s.spfilter,1,nil,e,tp)
			-- 并且检查对方的主要怪兽区是否还有空位可以进行特殊召唤
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 并且询问玩家是否确认要进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 给玩家发送提示：请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
			local tc=sg:GetFirst()
			-- 尝试将选中的怪兽表侧表示特殊召唤到对方场上
			if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
				-- 把其中1只怪兽在对方场上效果无效特殊召唤
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 把其中1只怪兽在对方场上效果无效特殊召唤
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 宣告这组并发的特殊召唤操作及附带效果均已完成处理
			Duel.SpecialSummonComplete()
		end
		-- 特殊召唤处理完成后，洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
