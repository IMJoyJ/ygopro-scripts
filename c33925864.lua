--六世壊根清浄
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有「俱舍怒威族」超量怪兽存在的场合才能发动。双方直到自身场上的怪兽变成1只为止必须里侧表示除外。
-- ②：这张卡被除外的场合，以自己场上1只「俱舍怒威族」超量怪兽为对象才能发动。那只怪兽作为超量素材中的1只自己的「俱舍怒威族」怪兽加入手卡。那之后，可以把那只怪兽从手卡特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②
function s.initial_effect(c)
	-- ①：场上有「俱舍怒威族」超量怪兽存在的场合才能发动。双方直到自身场上的怪兽变成1只为止必须里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上1只「俱舍怒威族」超量怪兽为对象才能发动。那只怪兽作为超量素材中的1只自己的「俱舍怒威族」怪兽加入手卡。那之后，可以把那只怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断是否为场上的「俱舍怒威族」超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189) and c:IsType(TYPE_XYZ)
end
-- 判断场上有「俱舍怒威族」超量怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有「俱舍怒威族」超量怪兽存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置效果①的发动条件和处理目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上的怪兽组
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取对方场上的怪兽组
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 判断己方场上有超过1只怪兽且能除外
	local b1=#g1>1 and Duel.IsPlayerCanRemove(tp)
		and g1:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN,REASON_RULE)
	-- 判断对方场上有超过1只怪兽且能除外
	local b2=#g2>1 and Duel.IsPlayerCanRemove(1-tp)
		and g2:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	if chk==0 then return b1 or b2 end
	local g3=g1+g2
	-- 设置效果处理信息，指定除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g3,1,0,0)
end
-- 处理效果①的发动，分别除外双方场上多余的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的怪兽组
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取对方场上的怪兽组
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 判断己方场上有超过1只怪兽且能除外
	local b1=#g1>1 and Duel.IsPlayerCanRemove(tp)
		and g1:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN,REASON_RULE)
	-- 判断对方场上有超过1只怪兽且能除外
	local b2=#g2>1 and Duel.IsPlayerCanRemove(1-tp)
		and g2:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	if b1 then
		local ct=#g1-1
		-- 提示己方选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g1:FilterSelect(tp,Card.IsAbleToRemove,ct,ct,nil,tp,POS_FACEDOWN,REASON_RULE)
		-- 将选择的卡除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE)
	end
	if b2 then
		local ct=#g2-1
		-- 提示对方选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g2:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		-- 将选择的卡除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
-- 定义过滤函数，用于判断是否为「俱舍怒威族」怪兽且能加入手牌
function s.thfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x189)
		and c:IsAbleToHand() and c:GetOwner()==tp
end
-- 定义过滤函数，用于判断是否为场上的「俱舍怒威族」超量怪兽且其超量区有符合条件的怪兽
function s.xfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x189)
		and c:GetOverlayGroup():IsExists(s.thfilter,1,nil,tp)
end
-- 设置效果②的发动条件和处理目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xfilter(chkc,tp) end
	-- 判断是否存在符合条件的场上的「俱舍怒威族」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.xfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果的对象
	Duel.SelectTarget(tp,s.xfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息，指定回手和特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
-- 处理效果②的发动，将超量区的怪兽加入手牌并可特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local mg=tc:GetOverlayGroup():Filter(s.thfilter,nil,tp)
	if tc:IsRelateToEffect(e) and #mg>0 then
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local bc=mg:Select(tp,1,1,nil):GetFirst()
		-- 将选择的卡加入手牌
		if Duel.SendtoHand(bc,nil,REASON_EFFECT)>0
			and bc:IsLocation(LOCATION_HAND) then
			-- 确认对方看到加入手牌的卡
			Duel.ConfirmCards(1-tp,bc)
			-- 洗切己方手牌
			Duel.ShuffleHand(tp)
			-- 判断己方场上是否有空位
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问是否特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将选择的卡特殊召唤
				Duel.SpecialSummon(bc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
