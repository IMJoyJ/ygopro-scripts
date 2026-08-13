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
-- ①效果免疫的判定函数：判断要免疫的外来效果是否来自「洞」或「落穴」字段的陷阱卡，若是则返回真，使本卡不受该效果影响。
function c28201945.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- ②效果的发动条件判定：当本卡持有者（自己）发动「洞」或「落穴」字段的陷阱卡时，满足条件，允许发动②效果。
function c28201945.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 检索/特殊召唤的卡片筛选函数：选择「虫惑魔」字段且卡名不是「卡祖拉之虫惑魔」的怪兽，并满足能够加入手卡或在有空格时可被特殊召唤。
function c28201945.filter(c,e,tp,ft)
	return c:IsSetCard(0x108a) and not c:IsCode(28201945) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ②效果发动时的合法性检查：计算我方怪兽区空格数，并确认卡组中存在至少1只符合条件的「虫惑魔」怪兽，若不存在则不能发动。
function c28201945.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上怪兽区的可用空格数量，用于后续判断是否可以特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动时点（chk==0）检查卡组中是否存在至少1张满足filter筛选条件的「虫惑魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28201945.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- ②效果的解决处理：从卡组选择1只符合条件的「虫惑魔」怪兽；若我方怪兽区有空格且该卡可特殊召唤，并且（该卡不能加入手卡或玩家选择了特殊召唤）则特殊召唤，否则将其加入手卡并让对方确认。
function c28201945.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区的可用空格数量，用于后续特殊召唤的判断。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 设置选择提示，告知玩家接下来需要从卡组选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张符合filter条件的「虫惑魔」怪兽作为效果处理对象。
	local g=Duel.SelectMatchingCard(tp,c28201945.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否选择特殊召唤：如果该卡不能加入手卡，或者玩家在二选一选项中选择了特殊召唤（返回1），则执行特殊召唤分支。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的「虫惑魔」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的「虫惑魔」怪兽加入其持有者手卡，由效果处理引发。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的卡片展示给对手确认。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
