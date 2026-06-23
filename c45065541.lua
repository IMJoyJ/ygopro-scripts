--伍世壊摘心
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「伍世坏-喜悦世界」加入手卡。自己场上有「伍世坏-喜悦世界」存在的场合，也能作为代替把「伍世坏摘心」以外的1张「末那愚子族」魔法·陷阱卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，包括①②两个效果
function s.initial_effect(c)
	-- 记录该卡与「伍世坏-喜悦世界」和「维萨斯-斯塔弗罗斯特」的关联
	aux.AddCodeList(c,56099748,82460246)
	-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「伍世坏-喜悦世界」加入手卡。自己场上有「伍世坏-喜悦世界」存在的场合，也能作为代替把「伍世坏摘心」以外的1张「末那愚子族」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果发动时需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断场上是否存在「伍世坏-喜悦世界」
function s.filter1(c)
	return c:IsFaceup() and c:IsCode(82460246)
end
-- 判断卡组中是否存在满足条件的卡（「伍世坏-喜悦世界」或「末那愚子族」魔法·陷阱卡）
function s.thfilter(c,check)
	local b1=c:IsCode(82460246)
	local b2=check and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x190)
	return not c:IsCode(id) and (b1 or b2) and c:IsAbleToHand()
end
-- 判断是否满足①效果的发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查场上是否存在「伍世坏-喜悦世界」
	local check=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil)
	-- 检查场上是否存在可选择破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,check) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的怪兽
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，指定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息，指定要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的发动，破坏目标怪兽并检索卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择破坏的怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽是否有效并执行破坏
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	-- 再次检查场上是否存在「伍世坏-喜悦世界」
	local check=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,check)
	if #g==0 then return end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
-- 判断手牌中是否存在可特殊召唤的怪兽（「维萨斯-斯塔弗罗斯特」或攻击力1500/守备力2100的怪兽）
function s.spfilter(c,e,tp)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	return (b1 or b2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足②效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查召唤区域是否为空
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，指定要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理②效果的发动，从手牌特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查召唤区域是否为空
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
