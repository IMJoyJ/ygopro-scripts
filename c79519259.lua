--ナイトウィング・プリースト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1张「爆裂模式」在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：丢弃1张手卡才能发动。从卡组选有「爆裂模式」的卡名记述的1只怪兽加入手卡或特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（特殊召唤时盖放「爆裂模式」）和②效果（丢弃手牌检索或特召记有「爆裂模式」的怪兽）
function s.initial_effect(c)
	-- 注册该卡片记述了「爆裂模式」（卡号80280737）的事实
	aux.AddCodeList(c,80280737)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1张「爆裂模式」在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡才能发动。从卡组选有「爆裂模式」的卡名记述的1只怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡名为「爆裂模式」且可以盖放到魔陷区
function s.setfilter(c)
	return c:IsCode(80280737) and c:IsSSetable()
end
-- ①效果的发动准备：检查魔陷区是否有空位，且手卡、卡组或墓地是否存在可以盖放的「爆裂模式」
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔陷区空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在可以盖放的「爆裂模式」
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
end
-- ①效果的执行：从手卡、卡组或墓地选择1张「爆裂模式」在场上盖放，并允许该卡在盖放的回合发动
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若魔陷区已无空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从手卡、卡组、墓地中选择1张不受墓地限制效果影响的「爆裂模式」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"适用「黑翼的祭司」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动代价：丢弃1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名记述有「爆裂模式」的怪兽，且可以加入手卡或可以特殊召唤
function s.thfilter(c,e,tp)
	-- 过滤出文本中记述有「爆裂模式」的怪兽卡
	if not (aux.IsCodeListed(c,80280737) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的发动准备：检查卡组中是否存在满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡或特殊召唤的、记有「爆裂模式」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ②效果的执行：从卡组选1只记有「爆裂模式」的怪兽加入手卡或特殊召唤，并适用“本回合不能从额外卡组特殊召唤同调怪兽以外的怪兽”的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取当前自己场上可用的怪兽区域数量，用于判断是否可以特殊召唤
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否只能加入手卡，或者在可以特召且有空位的情况下，由玩家选择将其加入手卡
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家本回合不能从额外卡组特殊召唤同调怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件：不能特殊召唤非同调怪兽，且该限制仅适用于从额外卡组进行的特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
