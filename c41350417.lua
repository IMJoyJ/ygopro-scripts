--黒魔導のカーテン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方各自可以从自身的手卡·卡组把1只魔法师族·暗属性怪兽特殊召唤。这个效果让自己特殊召唤的怪兽的原本卡名是「黑魔术师」或「黑魔术少女」的场合，再让自己可以把除「黑魔导的幕帘」外的1张有「黑魔术师」的卡名记述的魔法·陷阱卡从卡组加入手卡。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册「黑魔术师」和「黑魔术少女」卡名记述，以及双方各可特召暗属性魔法师族怪兽并可追加检索魔陷卡的发动效果
function s.initial_effect(c)
	-- 记录此卡文本上记述了「黑魔术师」和「黑魔术少女」卡名
	aux.AddCodeList(c,46986414,38033121)
	-- 这个卡名的卡在1回合只能发动1张。 ①：双方各自可以从自身的手卡·卡组把1只魔法师族·暗属性怪兽特殊召唤。这个效果让自己特殊召唤的怪兽的原本卡名是「黑魔术师」或「黑魔术少女」的场合，再让自己可以把除「黑魔导的幕帘」外的1张有「黑魔术师」的卡名记述的魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为魔法师族·暗属性且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，检查是否为处于公开状态、魔法师族·暗属性且可特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsPublic() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查，确认自己或对方至少有一方当前具备从手卡·卡组特殊召唤魔法师族·暗属性怪兽的可能性
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·卡组是否存在可特殊召唤的魔法师族·暗属性怪兽
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and
		-- 检查自己主要怪兽区是否至少有1个空位
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=false
	-- 检查对方怪兽区是否有空位且对方允许进行特殊召唤
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) then
		-- 检查对方卡组是否有卡或手卡中是否存在未公开的卡
		if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 or Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) then
			for lv=1,12 do
				-- 试探对方是否可以特殊召唤对应等级的魔法师族·暗属性怪兽
				if Duel.IsPlayerCanSpecialSummonMonster(1-tp,0,0,TYPE_MONSTER,-2,-2,lv,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP) then
					b2=true
					break
				end
			end
		end
		-- 或者检查对方已公开的手卡中是否存在可特殊召唤的魔法师族·暗属性怪兽
		b2=b2 or Duel.IsExistingMatchingCard(s.spfilter2,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
	end
	if chk==0 then return b1 or b2 end
end
-- 过滤函数，检查是否为除「黑魔导的幕帘」外、记述了「黑魔术师」卡名且可加入手卡的魔法·陷阱卡
function s.thfilter(c)
	-- 判断卡片非此卡同名卡、文本记述「黑魔术师」、属于魔法·陷阱卡且可加入手卡
	return not c:IsCode(id) and aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理，按回合玩家优先顺序由双方各自选择是否从手卡·卡组特召魔法师族·暗属性怪兽，封锁特召怪兽本回合效果发动，并判断是否满足追加检索条件
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	local ss=false
	-- 按当前回合玩家先、对方后的顺序依次遍历双方玩家
	for p in aux.TurnPlayers() do
		-- 检查当前玩家p的怪兽区是否至少有1个空位
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0
			-- 检查玩家p手卡·卡组是否存在可特殊召唤的魔法师族·暗属性怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,p)
			-- 询问玩家p是否要特殊召唤1只魔法师族·暗属性怪兽
			and Duel.SelectYesNo(p,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 提示玩家p选择要从手卡·卡组特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 由玩家p从自身手卡·卡组选择1只魔法师族·暗属性怪兽
			local sc=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,p):GetFirst()
			-- 以分步方式开始将选中的怪兽表侧表示特殊召唤到玩家p场上
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
		-- 完成双方分步特殊召唤处理并正式将其视作特殊召唤成功
		Duel.SpecialSummonComplete()
	end
	-- 检查自己是否特召了「黑魔术师」或「黑魔术少女」且卡组存在可检索的魔法·陷阱卡
	if res and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问自己是否从卡组把1张符合条件的魔法·陷阱卡加入手卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
		-- 中断当前效果处理，使后续加入手卡与前面的特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 提示自己从卡组选择要加入手卡的魔法·陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1张除「黑魔导的幕帘」外记述「黑魔术师」的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的魔法·陷阱卡加入自己手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的魔法·陷阱卡
		Duel.ConfirmCards(1-tp,g)
	end
end
