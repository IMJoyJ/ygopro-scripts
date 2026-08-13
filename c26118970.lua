--レッドローズ・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从手卡·卡组把「赤蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。这张卡作为「黑蔷薇龙」或植物族同调怪兽的同调素材送去墓地的场合，可以再从卡组把1张「冷蔷薇的抱香」或「漆黑之蔷薇的开华」加入手卡。
function c26118970.initial_effect(c)
	-- 将「黑蔷薇龙」的卡号73580471登记在本卡的代码列表中，用于后续判断这张卡作为同调素材时是否与「黑蔷薇龙」相关。
	aux.AddCodeList(c,73580471)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡作为同调素材送去墓地的场合才能发动。从手卡·卡组把「赤蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。这张卡作为「黑蔷薇龙」或植物族同调怪兽的同调素材送去墓地的场合，可以再从卡组把1张「冷蔷薇的抱香」或「漆黑之蔷薇的开华」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26118970,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,26118970)
	e1:SetCondition(c26118970.spcon)
	e1:SetTarget(c26118970.sptg)
	e1:SetOperation(c26118970.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：这张卡作为同调素材被送去墓地后处于墓地，且送去墓地的原因为同调召唤（REASON_SYNCHRO）。
function c26118970.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 特殊召唤候选卡的过滤函数：候选卡必须是「蔷薇龙」字段怪兽、卡名不是「赤蔷薇龙」本身，并且可以被当前效果特殊召唤。
function c26118970.spfilter(c,e,tp)
	return c:IsSetCard(0x1123) and not c:IsCode(26118970) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前检查：自己场上是否有可用主要怪兽区，并且手卡·卡组中存在至少1只满足spfilter的「蔷薇龙」怪兽。
function c26118970.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有至少1个空的主要怪兽区，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足spfilter条件（即「赤蔷薇龙」以外的「蔷薇龙」怪兽）的卡。
		and Duel.IsExistingMatchingCard(c26118970.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息：本次效果将进行特殊召唤，对象不确定，数量为1，来源为手卡·卡组，供系统进行相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	local rc=e:GetHandler():GetReasonCard()
	if rc and (rc:IsCode(73580471) or (rc:IsRace(RACE_PLANT) and rc:IsType(TYPE_SYNCHRO))) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetLabel(0)
	end
end
-- 追加检索的过滤函数：候选卡必须是「冷蔷薇的抱香」（53503015）或「漆黑之蔷薇的开华」（99092624），并且当前可以加入手卡。
function c26118970.thfilter(c)
	return c:IsCode(53503015,99092624) and c:IsAbleToHand()
end
-- 效果处理的实际操作：先选择并特殊召唤1只符合条件的「蔷薇龙」怪兽；若这张卡作为「黑蔷薇龙」或植物族同调怪兽的同调素材时（由e:GetLabel()标记），且玩家愿意，则再从卡组将1张「冷蔷薇的抱香」或「漆黑之蔷薇的开华」加入手卡。
function c26118970.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用主要怪兽区，则无法进行特殊召唤，效果处理直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1张满足spfilter条件的「蔷薇龙」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c26118970.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 判断特殊召唤是否成功执行，并且该卡作为「黑蔷薇龙」或植物族同调怪兽的同调素材发动时（label为1）才继续后续追加检索。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetLabel()==1
		-- 在满足追加条件后，检查卡组中是否存在可加入手卡的「冷蔷薇的抱香」或「漆黑之蔷薇的开华」，并询问玩家是否将其加入手卡。
		and Duel.IsExistingMatchingCard(c26118970.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(26118970,1)) then  --"是否选卡加入手卡？"
		-- 向玩家显示选择提示，要求选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张满足thfilter条件的卡（即「冷蔷薇的抱香」或「漆黑之蔷薇的开华」）。
		local g2=Duel.SelectMatchingCard(tp,c26118970.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			-- 将选择的那张卡以效果原因加入玩家手卡。
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
			-- 将加入手卡的那张卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
