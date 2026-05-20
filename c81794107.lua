--R.B. Lambda Cannon
-- 效果：
-- 这张卡召唤·特殊召唤的场合：可以以「奏悦机组 λ羔羊炮」以外的自己墓地1只「奏悦机组」怪兽为对象；那只怪兽加入手卡。
-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1200基本分；这张卡破坏，把对方的手卡确认，那之后可以把其中1只怪兽在对方场上效果无效特殊召唤。
-- 「奏悦机组 λ羔羊炮」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①召唤·特殊召唤成功时回收墓地怪兽的效果，以及②在连接怪兽所连接区存在时破坏自身并确认对方手卡、特召其中怪兽的效果
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
-- 过滤条件：自己墓地「奏悦机组 λ羔羊炮」以外的「奏悦机组」怪兽，且可以加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查墓地是否存在合法目标，让玩家选择目标并设置回收手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足回收条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择1只满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示该效果包含将墓地的目标卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
-- 效果①的效果处理：将选中的目标怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否仍与当前连锁相关，且不受「王家之谷」的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 效果②的发动条件检查：检查自身是否处于「奏悦机组」连接怪兽所连接的区域
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历所有找到的「奏悦机组」连接怪兽，合并它们所连接的区域
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 效果②的发动代价处理：检查并支付1200基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1200基本分
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 扣除玩家1200基本分
	Duel.PayLPCost(tp,1200)
end
-- 效果②的发动准备：检查对方手卡是否存在未公开的卡，并设置破坏自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在至少1张未公开的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
	-- 设置连锁操作信息，表示该效果包含破坏自身的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 过滤条件：可以由当前效果在对方场上以表侧表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果②的效果处理：破坏自身，确认对方手卡，并可选择其中1只怪兽在对方场上效果无效特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与当前连锁相关，并尝试将其破坏，若破坏失败则终止处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取对方手卡的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 让己方玩家确认对方的所有手卡
		Duel.ConfirmCards(tp,g)
		if g:IsExists(s.spfilter,1,nil,e,tp)
			-- 检查对方场上是否有可用的怪兽区域
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
			local tc=sg:GetFirst()
			-- 尝试将选中的怪兽以表侧表示特殊召唤到对方场上（分解步骤）
			if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成特殊召唤的后续处理
			Duel.SpecialSummonComplete()
		end
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
