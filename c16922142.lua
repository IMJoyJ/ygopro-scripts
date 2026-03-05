--絢嵐たるクローゼア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。「绚岚之罗莎」以外的「绚岚」卡和「旋风」各最多1张从自己的卡组·墓地加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
-- ③：对方场上没有魔法·陷阱卡存在的场合，场上的这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册所有效果
function s.initial_effect(c)
	-- 记录该卡与卡号5318639（绚岚之罗莎）的关联
	aux.AddCodeList(c,5318639)
	-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。「绚岚之罗莎」以外的「绚岚」卡和「旋风」各最多1张从自己的卡组·墓地加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：对方场上没有魔法·陷阱卡存在的场合，场上的这张卡不会被战斗·效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	e4:SetCondition(s.indescon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
end
-- 判断是否为速攻魔法卡发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 设置特殊召唤的处理条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义检索卡牌的过滤条件
function s.thfilter(c,typ)
	return c:IsAbleToHand() and (c:IsSetCard(0x1d1) and not c:IsCode(id) or c:IsCode(5318639))
end
-- 检查选择的卡组是否满足条件（最多1张绚岚之罗莎，最多1张绚岚卡）
function s.gcheck(g)
	return g:FilterCount(Card.IsCode,nil,5318639)<=1
		and g:FilterCount(Card.IsSetCard,nil,0x1d1)<=1
end
-- 设置检索效果的处理条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组或墓地是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行检索效果的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 and g:CheckSubGroup(s.gcheck,1,2) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,2)
		if sg then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 确认玩家看到选中的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	-- 设置效果发动后直到回合结束时自己不能特殊召唤非风属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤的条件（非风属性怪兽）
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 定义魔法·陷阱卡的过滤条件
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断对方场上是否有魔法·陷阱卡
function s.indescon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断对方场上是否没有魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_ONFIELD,1,nil)
end
