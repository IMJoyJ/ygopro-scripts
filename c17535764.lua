--ゴキポール
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把1只4星昆虫族怪兽加入手卡。这个效果把通常怪兽加入的场合，可以再把那只怪兽从手卡特殊召唤。那之后，可以选持有这个效果特殊召唤的怪兽的攻击力以上的攻击力的场上1只怪兽破坏。
function c17535764.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被送去墓地的场合才能发动。从卡组把1只4星昆虫族怪兽加入手卡。这个效果把通常怪兽加入的场合，可以再把那只怪兽从手卡特殊召唤。那之后，可以选持有这个效果特殊召唤的怪兽的攻击力以上的攻击力的场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17535764,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,17535764)
	e1:SetTarget(c17535764.thtg)
	e1:SetOperation(c17535764.tgop)
	c:RegisterEffect(e1)
end
-- 定义检索候选卡的过滤条件：等级4、昆虫族且能被加入手卡的怪兽。
function c17535764.thfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 效果发动时的判定与操作信息设置：若卡组存在符合条件的4星昆虫族怪兽则允许发动，并预设检索回手牌的操作信息。
function c17535764.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判断：检查卡组中是否存在1张以上满足thfilter的卡片，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17535764.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果的处理信息：将进行1张卡从卡组加入手卡的处理，供相关卡牌/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义可被破坏怪兽的过滤条件：表侧表示且攻击力不低于指定值。
function c17535764.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- 效果处理函数：从卡组选择并加入手卡1只4星昆虫族怪兽；若加入的是通常怪兽且可特殊召唤，则询问是否将其特殊召唤；特殊召唤成功后再询问并选择破坏场上1只攻击力不低于那只怪兽的表侧表示怪兽。
function c17535764.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示信息，要求玩家从卡组选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter的4星昆虫族怪兽，并取第一张作为检索对象。
	local tc=Duel.SelectMatchingCard(tp,c17535764.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 若成功选择到卡片，则将那张卡加入手卡并确认其加入成功后才继续后续处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_NORMAL) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当加入的是通常怪兽且满足特殊召唤条件时，询问玩家是否将其从手卡特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(17535764,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续动作成为独立处理，符合效果原文中“那之后”的先后时点关系。
			Duel.BreakEffect()
			-- 将那只通常怪兽以表侧表示特殊召唤到自己的怪兽区域；若特殊召唤成功则继续之后的效果。
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 获取场上双方怪兽区域中所有表侧表示且攻击力不低于特殊召唤怪兽当前攻击力的怪兽，作为可破坏候选集合。
				local g=Duel.GetMatchingGroup(c17535764.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetAttack())
				-- 若存在可破坏候选且玩家选择同意破坏，则进入破坏处理；否则不处理。
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(17535764,2)) then  --"是否破坏怪兽？"
					-- 再次中断效果处理，使破坏处理与特殊召唤处理分离，符合效果原文的“那之后”时点。
					Duel.BreakEffect()
					-- 显示选择提示信息，要求玩家选择要破坏的场上1只怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
					local tc2=g:Select(tp,1,1,nil)
					-- 以效果原因破坏选择的怪兽并送去墓地。
					Duel.Destroy(tc2,REASON_EFFECT)
				end
			end
		end
	end
end
