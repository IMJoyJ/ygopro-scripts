--黒魔導のカーテン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方各自可以从自身的手卡·卡组把1只魔法师族·暗属性怪兽特殊召唤。这个效果让自己特殊召唤的怪兽的原本卡名是「黑魔术师」或「黑魔术少女」的场合，再让自己可以把除「黑魔导的幕帘」外的1张有「黑魔术师」的卡名记述的魔法·陷阱卡从卡组加入手卡。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
local s,id,o=GetID()
-- 注册卡片效果的函数
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「黑魔术师」和「黑魔术少女」的卡密码
	aux.AddCodeList(c,46986414,38033121)
	-- 双方各自可以从自身的手卡·卡组把1只魔法师族·暗属性怪兽特殊召唤。这个效果让自己特殊召唤的怪兽的原本卡名是「黑魔术师」或「黑魔术少女」的场合，再让自己可以把除「黑魔导 the Curtain」外的1张有「黑魔术师」的卡名记述的魔法·陷阱卡从卡组加入手卡。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：手卡或卡组中可以被特殊召唤的暗属性魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：手卡中已公开且可以被特殊召唤的暗属性魔法师族怪兽
function s.spfilter2(c,e,tp)
	return c:IsPublic() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 定义条件b1：自己手卡或卡组存在可特殊召唤的暗属性魔法师族怪兽
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and
		-- 且自己场上有空余的怪兽区域
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=false
	-- 判断对方场上是否有空余怪兽区域且对方是否可以进行特殊召唤
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) then
		-- 检测对方卡组是否有卡，或者手卡中是否存在未公开的卡
		if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 or Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) then
			for lv=1,12 do
				-- 检测对方是否可以特殊召唤指定星级的暗属性魔法师族怪兽
				if Duel.IsPlayerCanSpecialSummonMonster(1-tp,0,0,TYPE_MONSTER,-2,-2,lv,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP) then
					b2=true
					break
				end
			end
		end
		-- 更新条件b2：或者对方手卡中存在公开的可特殊召唤的暗属性魔法师族怪兽
		b2=b2 or Duel.IsExistingMatchingCard(s.spfilter2,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
	end
	if chk==0 then return b1 or b2 end
end
-- 过滤函数：卡组中除「黑魔导的幕帘」外有「黑魔术师」卡名记述的魔法·陷阱卡
function s.thfilter(c)
	-- 判断卡片是否为非同名、记述了「黑魔术师」的魔陷卡且可以加入手牌
	return not c:IsCode(id) and aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	local ss=false
	-- 遍历双方玩家（从当前回合玩家开始）
	for p in aux.TurnPlayers() do
		-- 判断当前玩家场上是否有空余的怪兽区域
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0
			-- 且当前玩家的手卡或卡组存在可特殊召唤的暗属性魔法师族怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,p)
			-- 当前玩家选择是否从手卡或卡组把1只怪兽特殊召唤
			and Duel.SelectYesNo(p,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 给当前玩家提示：选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 当前玩家选择1只手卡或卡组中满足条件的怪兽
			local sc=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,p):GetFirst()
			-- 将选择的怪兽在各自场上正面表侧表示特殊召唤（拆分步骤）
			if Duel.SpecialSummonStep(sc,0,p,p,false,false,POS_FACEUP) then
				ss=true
				-- 这个回合，这个效果特殊召唤的怪兽的效果不能发动。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				if p==tp then
					res=sc:IsOriginalCodeRule(46986414,38033121)
				end
			end
		end
	end
	if ss then
		-- 完成特殊召唤的全部步骤
		Duel.SpecialSummonComplete()
	end
	-- 如果自己召唤的是「黑魔术师」或「黑魔术少女」且自己卡组有满足条件的卡
	if res and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 自己选择是否将卡从卡组加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
		-- 中断效果处理，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 给玩家提示：选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择卡组中1张满足检索条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认检索到的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
