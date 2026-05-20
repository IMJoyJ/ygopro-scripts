--ノーザンクロスファイア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的怪兽的等级合计是10星以上的场合才能发动。从手卡·卡组选1只10星怪兽加入手卡或特殊召唤。
-- ②：对方场上的怪兽的等级合计是10星以上的场合，从自己墓地把这张卡和1只10星怪兽除外，以对方场上1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的检索/特召效果和②的墓地除外解场效果
function s.initial_effect(c)
	-- ①：自己场上的怪兽的等级合计是10星以上的场合才能发动。从手卡·卡组选1只10星怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽的等级合计是10星以上的场合，从自己墓地把这张卡和1只10星怪兽除外，以对方场上1张卡为对象才能发动。那张卡除外。
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
-- ①效果的发动条件判定：自己场上表侧表示怪兽的等级合计在10星以上
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g>0 and g:GetSum(Card.GetLevel)>=10
end
-- 过滤手卡或卡组中满足条件的10星怪兽（可加入手卡，或在怪兽区域有空位时可特殊召唤）
function s.thfilter(c,e,tp,ft)
	return c:IsLevel(10) and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_DECK) and c:IsAbleToHand()
			or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动准备与合法性检测（检查手卡或卡组是否存在可检索或特召的10星怪兽）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查手卡或卡组中是否存在至少1张满足条件的10星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,ft) end
end
-- ①效果的处理：从手卡或卡组选1只10星怪兽，加入手卡或特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从手卡或卡组选择1张满足条件的10星怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		local thchk=tc:IsLocation(LOCATION_DECK) and tc:IsAbleToHand()
		local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 如果该卡可以特殊召唤，且不能加入手卡或玩家选择特殊召唤
		if spchk and (not thchk or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif thchk then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- ②效果的发动条件判定：对方场上表侧表示怪兽的等级合计在10星以上
function s.excon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return #g>0 and g:GetSum(Card.GetLevel)>=10
end
-- 过滤墓地中可作为cost除外的10星怪兽
function s.costfilter(c)
	return c:IsLevel(10) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价（cost）判定与执行：从墓地除外这张卡和1只10星怪兽
function s.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在除这张卡以外的、可作为cost除外的10星怪兽
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1张除这张卡以外的10星怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的墓地怪兽和这张卡一起除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标选择与合法性检测（以对方场上1张卡为对象）
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片（作为效果对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：除外对方场上的那1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理：将作为对象的对方场上的卡除外
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsOnField() then
		-- 将作为对象的卡片除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
