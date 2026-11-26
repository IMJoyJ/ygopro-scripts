--カズーラの蟲惑魔
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ②：自己把「洞」通常陷阱卡或者「落穴」通常陷阱卡发动的场合才能发动。从卡组选「卡祖拉之虫惑魔」以外的1只「虫惑魔」怪兽加入手卡或特殊召唤。
function c28201945.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c28201945.efilter)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己把「洞」通常陷阱卡或者「落穴」通常陷阱卡发动的场合才能发动。从卡组选「卡祖拉之虫惑魔」以外的1只「虫惑魔」怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28201945,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 免疫效果过滤函数：判断来袭效果的来源卡是否为「落穴」或「洞」字段的通常陷阱卡。
function c28201945.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- ②效果的发动条件：检查自己是否发动了「落穴」或「洞」字段的通常陷阱卡。
function c28201945.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 过滤条件：检查卡片是否为除「卡祖拉之虫惑魔」外且可加入手卡或（有空位时）可特招的「虫惑魔」怪兽。
function c28201945.filter(c,e,tp,ft)
	return c:IsSetCard(0x108a) and not c:IsCode(28201945) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ②效果的目标处理函数：获取己方怪兽区空位数并检查卡组是否存在符合条件的「虫惑魔」怪兽。
function c28201945.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动条件检查：确认自己卡组存在至少1只满足条件的「虫惑魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28201945.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- ②效果的处理函数：从卡组选1只「卡祖拉之虫惑魔」以外的「虫惑魔」怪兽，根据情况或玩家选择将其加入手卡或特殊召唤。
function c28201945.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发送提示信息，引导玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只「卡祖拉之虫惑魔」以外的「虫惑魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28201945.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若所选怪兽可特殊召唤且无法加入手卡或玩家选择特殊召唤时进入特殊召唤分支。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将所选「虫惑魔」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将所选「虫惑魔」怪兽以效果加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的怪兽展示给对方确认。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
