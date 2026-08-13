--Gゴーレム・ペブルドッグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：这张卡从手卡送去墓地的场合才能发动。从卡组把1张「G石人」卡加入手卡。
function c25273572.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25273572,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,25273572)
	e1:SetTarget(c25273572.sptg)
	e1:SetOperation(c25273572.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡送去墓地的场合才能发动。从卡组把1张「G石人」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25273572,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,25273573)
	e3:SetCondition(c25273572.thcon)
	e3:SetTarget(c25273572.thtg)
	e3:SetOperation(c25273572.thop)
	c:RegisterEffect(e3)
end
-- 定义检索/特殊召唤的候选卡筛选条件：卡名必须是「G石人·卵石斗牛犬」，且满足“可以加入手卡”或“场上存在可用的怪兽区且该卡可以特殊召唤”。
function c25273572.filter(c,e,tp,ft)
	return c:IsCode(25273572) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动合法性判定：检查自己卡组中是否存在至少1张符合条件的「G石人·卵石斗牛犬」，并计算可用的怪兽区数量ft供后续使用。
function c25273572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上当前可用的怪兽区域数量，用于判断是否满足特殊召唤所需的空间。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动合法性检查时，确认卡组中存在至少1张满足filter条件的「G石人·卵石斗牛犬」，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25273572.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- 执行①效果的检索/特殊召唤部分：从卡组选择1只符合条件的「G石人·卵石斗牛犬」，若场上有空位且该卡可以特殊召唤且玩家选择“特殊召唤”（或该卡不能加入手卡），则将其特殊召唤；否则将其加入手卡并让对手确认。
function c25273572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的怪兽区域数量，用于判断是否能够特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 显示选择卡片的提示消息，提示玩家“请选择要操作的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选出1张符合filter条件的「G石人·卵石斗牛犬」。
	local g=Duel.SelectMatchingCard(tp,c25273572.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否执行特殊召唤分支：需要场上有空位、选中的卡可以特殊召唤，并且满足“该卡不能加入手卡”或玩家在弹出的选项中选择了“特殊召唤”（选项序号为1）。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的「G石人·卵石斗牛犬」以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的「G石人·卵石斗牛犬」加入持有者的手卡，原因为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对手展示加入手卡的那张卡，以确认检索内容。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	-- ①效果的自肃部分：这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。②效果：这张卡从手卡送去墓地的场合才能发动。从卡组把1张「G石人」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25273572.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己不能特殊召唤电子界族以外怪兽”的自肃效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的限制条件：当要特殊召唤的怪兽不是电子界族时（返回true），该特殊召唤被禁止。
function c25273572.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- ②效果的发动条件：检查这张卡在送去墓地前的位置是手牌（即确实是从手卡被送入墓地）。
function c25273572.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 定义②效果检索卡牌的筛选条件：属于「G石人」系列（SetCard 0x186）且可以加入手卡。
function c25273572.thfilter(c)
	return c:IsSetCard(0x186) and c:IsAbleToHand()
end
-- ②效果的发动合法性判定：检查卡组中是否存在至少1张符合条件的「G石人」卡，并设置操作信息为从卡组检索1张加入手卡。
function c25273572.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认卡组中存在至少1张满足thfilter条件的「G石人」卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25273572.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息，标明此效果是从卡组将1张卡加入手卡（CATEGORY_TOHAND），用于效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果：从卡组选择1张符合条件的「G石人」卡加入手卡，并给对手确认。
function c25273572.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择卡片的提示消息，提示玩家“请选择要加入手卡的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张符合thfilter条件的「G石人」卡。
	local g=Duel.SelectMatchingCard(tp,c25273572.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「G石人」卡加入持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手卡的那张卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
