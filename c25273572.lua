--Gゴーレム・ペブルドッグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：这张卡从手卡送去墓地的场合才能发动。从卡组把1张「G石人」卡加入手卡。
function c25273572.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25273572,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 过滤函数：筛选卡组中「G石人·卵石斗牛犬」(25273572)且可加入手卡或（在有空位时）可特殊召唤的卡片
function c25273572.filter(c,e,tp,ft)
	return c:IsCode(25273572) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果①的Target函数：检测当前怪兽区空位数并确认卡组中存在可加入手卡或特召的同名卡
function c25273572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动检测时确认己方卡组中存在至少1只可操作的「G石人·卵石斗牛犬」
	if chk==0 then return Duel.IsExistingMatchingCard(c25273572.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- 效果①的Operation函数：从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤
function c25273572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向己方玩家发送选择要操作的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的「G石人·卵石斗牛犬」
	local g=Duel.SelectMatchingCard(tp,c25273572.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若该卡无法加入手卡，或玩家在加入手卡(1190)与特殊召唤(1152)之间选择了特殊召唤，则执行特召分支
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的「G石人·卵石斗牛犬」以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 以效果将选中的「G石人·卵石斗牛犬」加入持有者（己方）手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的「G石人·卵石斗牛犬」
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25273572.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续到回合结束阶段的特召种族限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制过滤函数：禁止特殊召唤非电子界族(RACE_CYBERSE)的怪兽
function c25273572.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 效果②的Condition函数：检查这张卡送去墓地前的位置是否为手卡
function c25273572.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤函数：筛选卡组中属于「G石人」(0x186)字段且可以加入手卡的卡片
function c25273572.thfilter(c)
	return c:IsSetCard(0x186) and c:IsAbleToHand()
end
-- 效果②的Target函数：检测卡组中存在可检索的「G石人」卡，并设置从卡组把1张卡加入手卡的操作信息
function c25273572.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1张可加入手卡的「G石人」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25273572.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation函数：从卡组选择1张「G石人」卡加入己方手卡并向对方确认
function c25273572.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张可加入手卡的「G石人」卡
	local g=Duel.SelectMatchingCard(tp,c25273572.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果将选中的「G石人」卡加入持有者（己方）手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的「G石人」卡
		Duel.ConfirmCards(1-tp,g)
	end
end
