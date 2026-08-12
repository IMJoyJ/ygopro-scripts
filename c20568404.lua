--ジュラック・スティゴ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
-- ②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①破坏并送去墓地；②被战斗破坏时回到手卡
function s.initial_effect(c)
	-- 记录该卡为「朱罗纪剑龙」，用于后续效果识别
	aux.AddCodeList(c,id)
	-- ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏并送去墓地"
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：返回等级大于等于1且为恐龙族且能送去墓地的怪兽
function s.tgfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
-- 过滤函数：返回不是本卡且为朱罗纪卡组且等级大于等于1且为怪兽卡且能特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x22) and c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 检查函数：返回给定怪兽组的等级总和是否等于指定等级
function s.gcheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 效果①的发动时点处理函数，检查是否有可破坏的场上卡和可送去墓地的恐龙族怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上所有可破坏的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil,e,tp)
	-- 若未满足发动条件则返回false
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：破坏场上卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，执行破坏、送去墓地、特殊召唤等操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡进行破坏
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 显示选卡动画
	Duel.HintSelection(g)
	-- 执行破坏操作
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1只恐龙族怪兽从卡组送去墓地
		local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local gc=sg:GetFirst()
		-- 若送去墓地成功且场上还有召唤区域，则继续处理特殊召唤
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and ft>0 then
			local lv=gc:GetLevel()
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 获取玩家手牌和卡组中符合条件的怪兽
			local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
			-- 检查是否满足特殊召唤条件并询问玩家是否发动
			if tg:CheckSubGroup(s.gcheck,1,ft,lv) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local ssg=tg:SelectSubGroup(tp,s.gcheck,false,1,ft,lv)
				if ssg:GetCount()>0 then
					-- 中断当前效果处理，使后续效果不同时处理
					Duel.BreakEffect()
					-- 将符合条件的怪兽无视召唤条件特殊召唤
					Duel.SpecialSummon(ssg,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
	-- 设置永续效果：本回合不能特殊召唤非恐龙族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该永续效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的判断函数：非恐龙族怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_DINOSAUR)
end
-- 效果②的发动时点处理函数，检查是否有可返回手牌的表侧表示卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未满足发动条件则返回false
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置连锁操作信息：将卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- 效果②的发动处理函数，执行将卡返回手牌的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1张表侧表示卡返回手牌
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选卡动画
		Duel.HintSelection(g)
		-- 将选中的卡返回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
