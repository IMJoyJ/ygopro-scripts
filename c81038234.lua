--夢魔鏡の夢語らい
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「梦魔镜」怪兽为让自身的效果发动而被解放的场合，不去墓地回到持有者卡组。
-- ②：自己·对方的主要阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己墓地的卡以及除外的自己的卡之中选1张「圣光之梦魔镜」或者「黯黑之梦魔镜」在自己的场地区域表侧表示放置。那之后，可以把有放置的卡的卡名记述的1只怪兽从手卡特殊召唤。
function c81038234.initial_effect(c)
	-- 在卡片中注册其效果文本中记述的卡片密码（圣光之梦魔镜、黯黑之梦魔镜）。
	aux.AddCodeList(c,74665651,1050355)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「梦魔镜」怪兽为让自身的效果发动而被解放的场合，不去墓地回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetTarget(c81038234.rmtg)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
	-- ②：自己·对方的主要阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己墓地的卡以及除外的自己的卡之中选1张「圣光之梦魔镜」或者「黯黑之梦魔镜」在自己的场地区域表侧表示放置。那之后，可以把有放置的卡的卡名记述的1只怪兽从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81038234,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c81038234.tfcon)
	e3:SetCost(c81038234.tfcost)
	e3:SetTarget(c81038234.tftg)
	e3:SetOperation(c81038234.tfop)
	c:RegisterEffect(e3)
end
-- 过滤自身场上的「梦魔镜」怪兽因自身发动效果作为代价而被解放的情况。
function c81038234.rmtg(e,c)
	local re=c:GetReasonEffect()
	return c:IsSetCard(0x131) and c:IsReason(REASON_COST) and c:IsReason(REASON_RELEASE) and re and re:IsActivated() and re:GetHandler()==c
end
-- 效果②的发动条件函数：自己或对方的主要阶段。
function c81038234.tfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②的发动代价函数：将魔法与陷阱区域表侧表示的这张卡送去墓地。
function c81038234.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡作为发动代价送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤自己墓地或除外状态的「圣光之梦魔镜」或「黯黑之梦魔镜」。
function c81038234.tffilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(74665651,1050355)
end
-- 效果②的发动准备（Target）函数：检查是否存在可放置的卡。
function c81038234.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或除外的卡中是否存在至少1张「圣光之梦魔镜」或「黯黑之梦魔镜」。
	if chk==0 then return Duel.IsExistingMatchingCard(c81038234.tffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
-- 过滤手卡中可以特殊召唤且记述了所放置卡片卡名的怪兽。
function c81038234.spfilter(c,e,tp,code)
	-- 检查怪兽是否可以特殊召唤，且其卡片文本中是否记述了指定的卡名。
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(c,code)
end
-- 效果②的效果处理（Operation）函数：放置场地魔法，并可选地从手卡特殊召唤记述了该卡名的怪兽。
function c81038234.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己墓地或除外的卡中选择1张「圣光之梦魔镜」或「黯黑之梦魔镜」（受王家之谷影响）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c81038234.tffilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	if #tg==0 then return end
	-- 选中所选卡片并向双方玩家展示。
	Duel.HintSelection(tg)
	local tc=tg:GetFirst()
	-- 获取自己场地区域已存在的卡片。
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		-- 根据规则将原本存在的场地魔法卡送去墓地。
		Duel.SendtoGrave(fc,REASON_RULE)
		-- 中断当前效果处理，使后续的放置处理不与送去墓地视为同时进行。
		Duel.BreakEffect()
	end
	-- 将选择的卡在自己的场地区域表侧表示放置，若放置成功则继续处理。
	if Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
		-- 获取手卡中所有记述了所放置卡片卡名且可特殊召唤的怪兽。
		local g=Duel.GetMatchingGroup(c81038234.spfilter,tp,LOCATION_HAND,0,nil,e,tp,tc:GetCode())
		-- 若手卡有符合条件的怪兽、怪兽区域有空位，且玩家选择进行特殊召唤。
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(81038234,1)) then  --"是否从手卡特殊召唤怪兽？"
			-- 中断当前效果处理，使特殊召唤与放置处理不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
