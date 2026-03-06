--聖なる篝火
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽加入手卡。对方场上有暗属性怪兽存在，自己场上没有怪兽存在的场合，可以再从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c22007085.initial_effect(c)
	-- 效果原文：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22007085+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22007085.target)
	e1:SetOperation(c22007085.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的怪兽（圣夜骑士或龙族·光属性·7星）
function c22007085.filter(c)
	return c:IsAbleToHand()
		and (c:IsSetCard(0x159) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7))
end
-- 效果作用：设置连锁处理信息，准备从卡组检索满足条件的卡
function c22007085.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足发动条件（卡组中存在满足条件的卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c22007085.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：过滤对方场上存在的暗属性怪兽
function c22007085.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果作用：过滤可以特殊召唤的龙族·光属性·7星怪兽
function c22007085.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：执行效果处理，选择并加入手牌，判断是否满足特殊召唤条件
function c22007085.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c22007085.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方看到选中的卡
		Duel.ConfirmCards(1-tp,g)
		-- 效果作用：洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 效果作用：检查对方场上是否存在暗属性怪兽
		if Duel.IsExistingMatchingCard(c22007085.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			-- 效果作用：检查自己手牌中是否存在符合条件的龙族·光属性·7星怪兽
			and Duel.IsExistingMatchingCard(c22007085.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 效果作用：询问玩家是否发动特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(22007085,0)) then  --"是否特殊召唤？"
			-- 效果作用：中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 效果作用：选择满足条件的卡进行特殊召唤
			local sg=Duel.SelectMatchingCard(tp,c22007085.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 效果作用：将选中的卡特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
