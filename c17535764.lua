--ゴキポール
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把1只4星昆虫族怪兽加入手卡。这个效果把通常怪兽加入的场合，可以再把那只怪兽从手卡特殊召唤。那之后，可以选持有这个效果特殊召唤的怪兽的攻击力以上的攻击力的场上1只怪兽破坏。
function c17535764.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地的场合才能发动。
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
-- 检索条件过滤器：筛选4星昆虫族可以加入手牌的怪兽
function c17535764.thfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 效果发动时的处理：检查卡组是否存在满足条件的怪兽并设置操作信息
function c17535764.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17535764.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组检索怪兽的效果加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 破坏目标筛选器：筛选场上攻击力大于等于指定值的怪兽
function c17535764.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- 效果处理主函数：执行检索、特殊召唤和破坏的完整流程
function c17535764.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡牌：从卡组中选择满足条件的1张卡
	local tc=Duel.SelectMatchingCard(tp,c17535764.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 执行加入手牌：将选中的卡加入手牌并确认
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 确认手牌：向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_NORMAL) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问是否特殊召唤：询问玩家是否要特殊召唤该怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(17535764,1)) then  --"是否特殊召唤？"
			-- 中断效果：中断当前效果处理，避免错时点
			Duel.BreakEffect()
			-- 执行特殊召唤：将该怪兽特殊召唤到场上
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 获取可破坏怪兽：获取场上攻击力大于等于特殊召唤怪兽攻击力的怪兽
				local g=Duel.GetMatchingGroup(c17535764.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetAttack())
				-- 询问是否破坏：询问玩家是否要破坏场上怪兽
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(17535764,2)) then  --"是否破坏怪兽？"
					-- 中断效果：中断当前效果处理，避免错时点
					Duel.BreakEffect()
					-- 提示选择：提示玩家选择要破坏的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
					local tc2=g:Select(tp,1,1,nil)
					-- 执行破坏：将选中的怪兽破坏
					Duel.Destroy(tc2,REASON_EFFECT)
				end
			end
		end
	end
end
