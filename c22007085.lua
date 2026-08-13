--聖なる篝火
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽加入手卡。对方场上有暗属性怪兽存在，自己场上没有怪兽存在的场合，可以再从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c22007085.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽加入手卡。对方场上有暗属性怪兽存在，自己场上没有怪兽存在的场合，可以再从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22007085+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22007085.target)
	e1:SetOperation(c22007085.activate)
	c:RegisterEffect(e1)
end
-- 检索判定：能够加入手卡的「圣夜骑士」怪兽，或者龙族·光属性·7星怪兽。
function c22007085.filter(c)
	return c:IsAbleToHand()
		and (c:IsSetCard(0x159) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7))
end
-- 效果发动时的目标处理函数：检查卡组中是否存在满足检索条件的卡，并设置本次操作涉及从卡组加入手卡的操作信息。
function c22007085.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：卡组中存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22007085.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理中确定要将1张卡从卡组加入手卡（不取对象，处理时选择具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 追加特殊召唤条件判定1：对方场上有表侧表示的暗属性怪兽。
function c22007085.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 特殊召唤候选筛选：手牌中的龙族·光属性·7星怪兽，且满足该效果特殊召唤的限制条件。
function c22007085.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：从卡组选择1张符合条件的怪兽加入手卡，向对方展示并洗切手卡；若对方场上有暗属性怪兽且自己场上无怪兽、手牌有可特召的龙族·光属性·7星怪兽，则询问玩家是否特殊召唤，确认后从手卡特殊召唤。
function c22007085.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足检索条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c22007085.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手卡，避免对方从手牌位置推断出检索的卡。
		Duel.ShuffleHand(tp)
		-- 追加特殊召唤条件判定2：对方场上有暗属性怪兽，且自己场上没有怪兽。
		if Duel.IsExistingMatchingCard(c22007085.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			-- 追加特殊召唤条件判定3：手牌中存在可以进行特殊召唤的龙族·光属性·7星怪兽。
			and Duel.IsExistingMatchingCard(c22007085.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 询问玩家是否进行特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(22007085,0)) then  --"是否特殊召唤？"
			-- 中断当前效果链，使检索处理和后续特殊召唤不视为同时处理（错开时点）。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡选择1只满足条件的龙族·光属性·7星怪兽。
			local sg=Duel.SelectMatchingCard(tp,c22007085.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
