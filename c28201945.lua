--カズーラの蟲惑魔
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ②：自己把「洞」通常陷阱卡或者「落穴」通常陷阱卡发动的场合才能发动。从卡组选「卡祖拉之虫惑魔」以外的1只「虫惑魔」怪兽加入手卡或特殊召唤。
function c28201945.initial_effect(c)
	-- 效果原文内容：①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c28201945.efilter)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己把「洞」通常陷阱卡或者「落穴」通常陷阱卡发动的场合才能发动。从卡组选「卡祖拉之虫惑魔」以外的1只「虫惑魔」怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28201945,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,28201945)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c28201945.spcon)
	e3:SetTarget(c28201945.sptg)
	e3:SetOperation(c28201945.spop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：过滤掉类型为陷阱卡且种族为「洞」或「落穴」的卡的效果
function c28201945.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 规则层面操作：判断是否为己方发动的陷阱卡效果，且该陷阱卡为「洞」或「落穴」类型
function c28201945.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 规则层面操作：过滤满足条件的「虫惑魔」怪兽，且不能是自身，可以加入手牌或特殊召唤
function c28201945.filter(c,e,tp,ft)
	return c:IsSetCard(0x108a) and not c:IsCode(28201945) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 规则层面操作：检查是否满足条件的卡存在于卡组中，用于判断是否能发动效果
function c28201945.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 规则层面操作：如果满足条件的卡存在于卡组中，则效果可以发动
	if chk==0 then return Duel.IsExistingMatchingCard(c28201945.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- 规则层面操作：处理效果发动后的具体操作，包括选择卡、决定加入手牌或特殊召唤
function c28201945.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 规则层面操作：提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 规则层面操作：从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c28201945.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 规则层面操作：如果不能加入手牌，则选择特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 规则层面操作：将选中的卡特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 规则层面操作：将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 规则层面操作：确认对方看到该卡
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
