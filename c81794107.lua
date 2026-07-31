--R.B.ラムダキャノン
-- 效果：
-- 这张卡召唤·特殊召唤的场合：可以以「奏悦机组 λ羔羊炮」以外的自己墓地1只「奏悦机组」怪兽为对象；那只怪兽加入手卡。
-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1200基本分；这张卡破坏，把对方的手卡确认，那之后可以把其中1只怪兽在对方场上效果无效特殊召唤。
-- 「奏悦机组 λ羔羊炮」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①召·特召成功墓地「奏悦机组」怪兽回收效果、②连接区存在时支付基本分破坏自身确认对方手牌并特召怪兽效果
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
-- 墓地回收过滤条件：本名以外的「奏悦机组」怪兽且可加入手牌
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动准备：选择自己墓地1只满足条件的「奏悦机组」怪兽并设置连锁操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：墓地是否存在可回收的同字段怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地1只满足条件的「奏悦机组」怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：从墓地回收1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：将选中的墓地怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍关联连锁且不受王谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 连接怪兽过滤条件：场上表侧表示的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- ②效果发动条件：检查此卡是否处于「奏悦机组」连接怪兽的所连接区
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历所有「奏悦机组」连接怪兽合并其所连接区的区域集合
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- ②效果发动Cost：支付1200基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：玩家基本分是否不低于1200
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 扣除玩家1200基本分
	Duel.PayLPCost(tp,1200)
end
-- ②效果发动准备：检查对方手牌并设置破坏此卡的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在未公开的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
	-- 设置连锁操作信息：破坏此卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 对方场上特召过滤条件：可以表侧表示特殊召唤到对方场上的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- ②效果处理：破坏此卡，确认对方手牌，选择其中1只怪兽在对方场上效果无效特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡关联连锁并成功因效果破坏，未破坏则终止后续处理
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 获取对方全部手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 向己方玩家确认对方全部手牌
		Duel.ConfirmCards(tp,g)
		if g:IsExists(s.spfilter,1,nil,e,tp)
			-- 检查对方主要怪兽区域是否有空位
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择对方手牌的怪兽进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
			local tc=sg:GetFirst()
			-- 将选中怪兽以表侧表示特殊召唤到对方场上，并进行无效效果的分步处理
			if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
				-- 效果无效特殊召唤（无效怪兽属性）
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 效果无效特殊召唤（无效怪兽发动的效果）
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成特殊召唤过程
			Duel.SpecialSummonComplete()
		end
		-- 洗混对方手牌
		Duel.ShuffleHand(1-tp)
	end
end
