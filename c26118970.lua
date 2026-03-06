--レッドローズ・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从手卡·卡组把「赤蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。这张卡作为「黑蔷薇龙」或植物族同调怪兽的同调素材送去墓地的场合，可以再从卡组把1张「冷蔷薇的抱香」或「漆黑之蔷薇的开华」加入手卡。
function c26118970.initial_effect(c)
	-- 记录该卡为「黑蔷薇龙」的同名卡
	aux.AddCodeList(c,73580471)
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。从手卡·卡组把「赤蔷薇龙」以外的1只「蔷薇龙」怪兽特殊召唤。这张卡作为「黑蔷薇龙」或植物族同调怪兽的同调素材送去墓地的场合，可以再从卡组把1张「冷蔷薇的抱香」或「漆黑之蔷薇的开华」加入手卡。
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
-- 判断此卡是否因同调而被送入墓地
function c26118970.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤满足「蔷薇龙」卡组且非自身、可特殊召唤的怪兽
function c26118970.spfilter(c,e,tp)
	return c:IsSetCard(0x1123) and not c:IsCode(26118970) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，即场上有空位且手牌或卡组有符合条件的怪兽
function c26118970.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c26118970.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将特殊召唤1只怪兽
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
-- 过滤「冷蔷薇的抱香」或「漆黑之蔷薇的开华」卡
function c26118970.thfilter(c)
	return c:IsCode(53503015,99092624) and c:IsAbleToHand()
end
-- 执行效果处理，先选择并特殊召唤1只符合条件的怪兽，再判断是否满足额外效果条件并选择是否发动
function c26118970.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c26118970.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 确认已特殊召唤成功且满足额外效果触发条件
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetLabel()==1
		-- 判断卡组是否存在可加入手牌的卡并询问玩家是否发动额外效果
		and Duel.IsExistingMatchingCard(c26118970.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(26118970,1)) then  --"是否选卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择要加入手牌的卡
		local g2=Duel.SelectMatchingCard(tp,c26118970.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
