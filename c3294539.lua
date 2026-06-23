--クリムゾン・ブレード・ドラゴン
-- 效果：
-- 「共鸣者」调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上当作「深红剑士」使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地选1只8星以上的不能通常召唤的怪兽加入手卡或效果无效特殊召唤。
-- ②：这张卡和5星以上的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤程序并注册两个诱发效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只「共鸣者」调整+1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x57),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：从卡组或墓地选择1只8星以上不能通常召唤的怪兽加入手卡或特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：和5星以上的怪兽战斗时，那只怪兽破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：该卡为同调召唤成功时才能发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索过滤器函数，判断卡是否满足8星以上且不能通常召唤的条件
function s.thfilter(c,e,tp)
	if c:IsSummonableCard() or not c:IsType(TYPE_MONSTER) or not c:IsLevelAbove(8) then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果①的发动时的处理函数，检查是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- 效果①的发动处理函数，选择卡并进行操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择满足条件的卡组或墓地的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		local spf=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
		-- 判断是否选择将卡加入手卡或特殊召唤
		if tc:IsAbleToHand() and (not spf or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方查看该卡
			Duel.ConfirmCards(1-tp,tc)
		-- 判断是否选择特殊召唤
		elseif spf and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 给特殊召唤的怪兽添加无效化效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 给特殊召唤的怪兽添加无效化效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成特殊召唤操作
			Duel.SpecialSummonComplete()
		end
	end
end
-- 效果②的发动时的处理函数，检查是否满足发动条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsLevelAbove(5) and tc:IsControler(1-tp) end
	-- 设置连锁操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果②的发动处理函数，破坏目标怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
