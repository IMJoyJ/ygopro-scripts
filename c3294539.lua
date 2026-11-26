--クリムゾン・ブレード・ドラゴン
-- 效果：
-- 「共鸣者」调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上当作「深红剑士」使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地选1只8星以上的不能通常召唤的怪兽加入手卡或效果无效特殊召唤。
-- ②：这张卡和5星以上的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：设置同调召唤手续与复苏限制，并注册①效果（同调召唤从卡组·墓地检索或效果无效特召8星以上不能通常召唤的怪兽）与②效果（与5星以上怪兽战斗时将其破坏）
function s.initial_effect(c)
	-- 设置同调召唤条件：需要「共鸣者」调整1只＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x57),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 「共鸣者」调整＋调整以外的怪兽1只以上 这个卡名在规则上当作「深红剑士」使用。这个卡名的①的效果1回合只能使用1次。 ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地选1只8星以上的不能通常召唤的怪兽加入手卡或效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡和5星以上的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件检查：确认这张卡是通过同调召唤登场的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选条件：检查卡片是否为不能通常召唤的8星以上怪兽，且可加入手卡或在己方怪兽区有空位时可特殊召唤
function s.thfilter(c,e,tp)
	if c:IsSummonableCard() or not c:IsType(TYPE_MONSTER) or not c:IsLevelAbove(8) then return false end
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ①效果的发动检测：确认己方卡组或墓地存在至少1只符合条件的8星以上不能通常召唤的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方卡组·墓地存在可加入手卡或特殊召唤的8星以上不能通常召唤怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- ①效果的处理流程：从己方卡组·墓地选1只8星以上不能通常召唤的怪兽，使其加入手卡或将其效果无效后特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方提示选择要从卡组·墓地操作的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让己方从卡组·墓地（经王家长眠之谷过滤）选择1只满足条件的8星以上怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取当前己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		local spf=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
		-- 若该怪兽能加入手卡，且无法特殊召唤或己方选择加入手卡分支，则执行加入手卡
		if tc:IsAbleToHand() and (not spf or Duel.SelectOption(tp,1190,1152)==0) then
			-- 以效果将所选怪兽加入己方手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		-- 否则若满足特殊召唤条件，则执行分步特殊召唤将该怪兽以表侧表示召唤到己方场上
		elseif spf and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效特殊召唤。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成分步特殊召唤并统一触发召唤相关时点
			Duel.SpecialSummonComplete()
		end
	end
end
-- ②效果的发动检测与连锁信息设置：确认这张卡正与对方的5星以上表侧怪兽进行战斗，并登记破坏该战斗对象怪兽的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsLevelAbove(5) and tc:IsControler(1-tp) end
	-- 登记连锁的破坏操作信息，预计破坏与这张卡战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ②效果的处理流程：确认战斗对象怪兽仍在战斗中并将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 以效果将与这张卡进行战斗的5星以上怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
