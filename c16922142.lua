--絢嵐たるクローゼア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。「绚岚之罗莎」以外的「绚岚」卡和「旋风」各最多1张从自己的卡组·墓地加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
-- ③：对方场上没有魔法·陷阱卡存在的场合，场上的这张卡不会被战斗·效果破坏。
local s,id,o=GetID()
-- 注册卡片的全部效果：①速攻魔法卡发动时从手卡特殊召唤；②召唤·特殊召唤时从卡组·墓地检索「绚岚」和「旋风」及发动后的风属性自肃；③对方场上无魔法·陷阱时不因战斗·效果破坏。
function s.initial_effect(c)
	-- 将旋风（5318639）登记到本卡的卡名列表中，表示本卡效果文中记载了「旋风」卡名，供相关检索/判定使用。
	aux.AddCodeList(c,5318639)
	-- 这个卡名的①②的效果1回合各能使用1次。①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤的场合才能发动。「绚岚之罗莎」以外的「绚岚」卡和「旋风」各最多1张从自己的卡组·墓地加入手卡。
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
-- 效果①的发动条件：确认连锁中发动的效果为魔法卡的发动且该魔法卡是速攻魔法卡（速攻魔法卡发动的场合）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 效果①发动合法性的检查：自己主要怪兽区有空位，且手卡的这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在空位（要求能空出至少1个可用怪兽区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：将这张卡进行1次特殊召唤，用于连锁判定和相关时点。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：若这张卡仍与当前连锁相关，则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示将这张卡特殊召唤到自己场上（不限制表示形式，这里用表侧攻击表示）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索过滤：可从卡组·墓地加入手卡，且满足「绚岚」系列卡且不是本卡，或者「旋风」（5318639）的卡。
function s.thfilter(c,typ)
	return c:IsAbleToHand() and (c:IsSetCard(0x1d1) and not c:IsCode(id) or c:IsCode(5318639))
end
-- 选择子组合法性检查：所选卡中「旋风」最多1张且「绚岚」字段卡最多1张（符合‘各最多1张’）。
function s.gcheck(g)
	return g:FilterCount(Card.IsCode,nil,5318639)<=1
		and g:FilterCount(Card.IsSetCard,nil,0x1d1)<=1
end
-- 效果②发动合法性与处理信息：若卡组·墓地存在至少1张检索对象，则设置本次处理将1张卡加入手卡（来源卡组·墓地）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②发动合法性检查：从自己的卡组·墓地中确认存在至少1张符合s.thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次处理会使卡加入手卡（CATEGORY_TOHAND），且处理时从卡组·墓地中选择。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②处理：从卡组·墓地中选出符合条件的「绚岚」和「旋风」（各最多1张）加入手卡并展示给对方，然后给自己附加直到回合结束不能特殊召唤非风属性怪兽的自肃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前卡组·墓地中所有满足检索条件且不受王家长眠之谷影响的卡的集合，供效果处理时选择。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 and g:CheckSubGroup(s.gcheck,1,2) then
		-- 显示“请选择要加入手牌的卡”的选择提示，进入选择卡牌界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,2)
		if sg then
			-- 将选中的卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。③：对方场上没有魔法·陷阱卡存在的场合，场上的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册为该玩家场上的效果，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定函数：只要不是风属性怪兽就不能被特殊召唤（即只有风属性怪兽才能被特殊召唤）。
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤函数：检查一张卡是否为魔法·陷阱卡（用于判断对方场上是否存在魔法·陷阱卡）。
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③抗性条件的判定：获取这张卡的控制者，检查对方场上是否存在魔法·陷阱卡。
function s.indescon(e)
	local tp=e:GetHandlerPlayer()
	-- 返回对方场上不存在魔法·陷阱卡的判定结果，作为获得破坏免疫的条件。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_ONFIELD,1,nil)
end
