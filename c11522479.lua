--BK アッパーカッター
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤的场合才能发动。「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽或1张「反击」反击陷阱卡从卡组加入手卡。
-- ②：这张卡被效果送去墓地的场合，可以从以下效果选择1个发动。
-- ●从自己墓地把「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽特殊召唤。
-- ●从自己墓地把1张「反击」反击陷阱卡在自己场上盖放。
function c11522479.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽或1张「反击」反击陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11522479,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,11522479)
	e1:SetTarget(c11522479.thtg)
	e1:SetOperation(c11522479.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合，可以从以下效果选择1个发动。●从自己墓地把「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽特殊召唤。●从自己墓地把1张「反击」反击陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,11522479)
	e3:SetCondition(c11522479.lgcon)
	e3:SetTarget(c11522479.lgtg)
	e3:SetOperation(c11522479.lgop)
	c:RegisterEffect(e3)
end
-- 定义检索用过滤器：选择卡组中满足以下条件的卡——「燃烧拳击手」怪兽（卡名不是「燃烧拳击手 上勾拳手」）或「反击」反击陷阱卡，且该卡能够被加入手卡。
function c11522479.thfilter(c)
	return (c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and not c:IsCode(11522479)
		or c:IsSetCard(0x199) and c:IsType(TYPE_COUNTER)) and c:IsAbleToHand()
end
-- ①效果的发动条件判定：确认卡组存在可检索的符合条件的卡，并登记本次效果为从卡组加入手卡的操作信息。
function c11522479.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前的合法性检查：卡组中不存在满足检索条件的卡时，不能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c11522479.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将把1张卡从卡组加入手卡，用于连锁和针对效果的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合条件的卡加入手牌，并向对方展示确认。
function c11522479.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中精确选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c11522479.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将被选中的卡以效果原因送入（加入）其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索结果展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：这张卡是被效果原因送去墓地的场合（而不是战斗或代价等其他原因）。
function c11522479.lgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义特殊召唤过滤器：选择墓地中满足以下条件的卡——「燃烧拳击手」怪兽且卡名不是「燃烧拳击手 上勾拳手」，并且能够被当前效果特殊召唤。
function c11522479.spfilter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and not c:IsCode(11522479) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义盖放过滤器：选择墓地中满足以下条件的卡——「反击」系列反击陷阱卡，并且当前可以被盖放到魔法与陷阱区。
function c11522479.setfilter(c)
	return c:IsSetCard(0x199) and c:IsType(TYPE_COUNTER) and c:IsSSetable()
end
-- ②效果的目标判定：分别检查“从墓地特殊召唤怪兽”与“从墓地盖放反击陷阱”两个分支是否可行，并在可行时让玩家选择要执行的分支。
function c11522479.lgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格，作为特殊召唤分支可行的条件之一。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合spfilter条件（可特殊召唤的「燃烧拳击手」怪兽）的卡。
		and Duel.IsExistingMatchingCard(c11522479.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查墓地是否存在符合setfilter条件（可盖放的「反击」反击陷阱卡）的卡。
	local b2=Duel.IsExistingMatchingCard(c11522479.setfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 两个分支都可行时，让玩家在“特殊召唤怪兽”和“盖放反击陷阱”之间选择，用返回值0/1标记分支。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(11522479,1),aux.Stringid(11522479,2))  --"从墓地特殊召唤怪兽/从墓地盖放反击陷阱"
	-- 仅特殊召唤分支可行时，显示唯一选项“特殊召唤”，选择后分支标记为0。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(11522479,1))  --"从墓地特殊召唤怪兽"
	-- 仅盖放分支可行时，显示唯一选项“盖放”，由于SelectOption返回0，加1后分支标记为1。
	else op=Duel.SelectOption(tp,aux.Stringid(11522479,2))+1 end  --"从墓地盖放反击陷阱"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 登记操作信息：本次效果为从墓地特殊召唤1只怪兽，供连锁和相应判定使用。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
		-- 登记操作信息：本次效果为从墓地移动1张卡到魔陷区（盖放），属于涉及墓地离场的操作。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	end
end
-- ②效果处理：根据目标阶段选择的分支执行——分支0从墓地选1只「燃烧拳击手」怪兽（排除王家长眠之谷影响）特殊召唤；分支1从墓地选1张「反击」反击陷阱盖放到自己魔陷区。
function c11522479.lgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 特殊召唤处理前再次确认自己场上仍有可用的怪兽区空格，若无则直接终止处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家显示选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只满足特殊召唤条件且不受王家长眠之谷影响（能够离开墓地）的「燃烧拳击手」怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11522479.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 向玩家显示选择提示：请选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从墓地选择1张可盖放且不受王家长眠之谷影响的「反击」反击陷阱卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11522479.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的反击陷阱卡以里侧表示盖放到自己的魔法与陷阱区。
			Duel.SSet(tp,g)
		end
	end
end
