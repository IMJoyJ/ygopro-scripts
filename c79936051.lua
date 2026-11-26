--ノーザンクロスファイア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的怪兽的等级合计是10星以上的场合才能发动。从手卡·卡组选1只10星怪兽加入手卡或特殊召唤。
-- ②：对方场上的怪兽的等级合计是10星以上的场合，从自己墓地把这张卡和1只10星怪兽除外，以对方场上1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册检索或特召10星怪兽的①效果，以及从墓地除外自身与10星怪兽来除外对方1张卡的②效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。 ①：自己场上的怪兽的等级合计是10星以上的场合才能发动。从手卡·卡组选1只10星怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。 ②：对方场上的怪兽的等级合计是10星以上的场合，从自己墓地把这张卡和1只10星怪兽除外，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.excon)
	e2:SetCost(s.excost)
	e2:SetTarget(s.extg)
	e2:SetOperation(s.exop)
	c:RegisterEffect(e2)
end
-- 发动条件检查，确认自己场上表侧表示怪兽的等级合计在10以上
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己怪兽区所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g>0 and g:GetSum(Card.GetLevel)>=10
end
-- 过滤函数，检查是否为10星怪兽，且在卡组中时可加入手卡或在有空位时可特殊召唤
function s.thfilter(c,e,tp,ft)
	return c:IsLevel(10) and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_DECK) and c:IsAbleToHand()
			or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 发动条件检查，确认自己手卡·卡组存在至少1只符合条件的10星怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查自己手卡·卡组是否存在至少1只满足加入手卡或特殊召唤条件的10星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,ft) end
end
-- 效果处理，从自己手卡·卡组选1只10星怪兽加入手卡或表侧表示特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示控制者从手卡·卡组选择要加入手卡或特殊召唤的10星怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己手卡·卡组选择1只满足条件的10星怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		local thchk=tc:IsLocation(LOCATION_DECK) and tc:IsAbleToHand()
		local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是特殊召唤还是加入手卡（无法加手或玩家选择特召时执行特殊召唤）
		if spchk and (not thchk or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的10星怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif thchk then
			-- 将选中的卡组10星怪兽加入自己手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的10星怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 发动条件检查，确认对方场上表侧表示怪兽的等级合计在10以上
function s.excon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方怪兽区所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return #g>0 and g:GetSum(Card.GetLevel)>=10
end
-- 过滤函数，检查是否为墓地中可作为代价除外的10星怪兽
function s.costfilter(c)
	return c:IsLevel(10) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理，检查并将墓地的这张卡与1只10星怪兽表侧表示除外
function s.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在除这张卡外至少1只可作为代价除外的10星怪兽
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示控制者从自己墓地选择1只作为代价除外的10星怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只10星怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选中的10星怪兽和墓地的这张卡一起表侧除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查对方场上是否存在可除外的卡，选择1张作为对象并设置除外操作信息
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可作为对象除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示控制者选择对方场上要除外的1张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可除外的卡作为本次连锁的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置将对象卡除外的作用信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理，确认对象卡仍与连锁关联且在场上后将其表侧表示除外
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象选择的对方场上的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsOnField() then
		-- 将作为对象的对方场上的卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
