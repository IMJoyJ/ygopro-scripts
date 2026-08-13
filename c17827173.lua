--ふわんだりぃず×とっかん
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：这张卡召唤成功的场合，以除外的1张自己的「随风旅鸟」卡为对象才能发动。那张卡加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
-- ②：表侧表示的这张卡从场上离开的场合除外。
-- ③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
function c17827173.initial_effect(c)
	-- 对应①效果及共通自肃：这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的场合，以除外的1张自己的「随风旅鸟」卡为对象才能发动。那张卡加入手卡。那之后，可以把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17827173,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,17827173)
	e1:SetCost(c17827173.cost)
	e1:SetTarget(c17827173.thtg)
	e1:SetOperation(c17827173.thop)
	c:RegisterEffect(e1)
	-- 给这张卡附加“表侧表示的这张卡从场上离开的场合除外”的重定向效果，使其从场上表侧表示离开时改为除外而不是送去墓地。
	aux.AddBanishRedirect(c)
	-- 对应③效果及共通自肃：这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17827173,1))  --"这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,17827174)
	e3:SetCondition(c17827173.thcon2)
	e3:SetCost(c17827173.cost)
	e3:SetTarget(c17827173.thtg2)
	e3:SetOperation(c17827173.thop2)
	c:RegisterEffect(e3)
end
-- ①③效果共同的发动代价：检查本回合自己尚未特殊召唤过，然后给自己附加“不能特殊召唤怪兽”的誓约效果（持续到结束阶段）。
function c17827173.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：只有当自己本回合的特殊召唤次数为0（即本回合尚未特殊召唤过）时，该效果才能发动。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 对应卡片效果原文：这个卡名的①③的效果1回合各能使用1次，这些效果发动的回合，自己不能把怪兽特殊召唤。①：这张卡召唤成功的场合，以除外的1张自己的「随风旅鸟」卡为对象才能发动。那张卡加入手卡。那之后，可以把1只鸟兽族怪兽召唤。③：这张卡除外中的状态，自己场上有鸟兽族怪兽召唤的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将刚生成的“不能特殊召唤”自肃效果注册到场上，使其对控制者tp生效（效果持续到结束阶段）。
	Duel.RegisterEffect(e1,tp)
end
-- ①效果的取对象筛选条件：对象必须是除外区表侧表示、卡名含有“随风旅鸟”字段且能被加入手卡的自己的卡。
function c17827173.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16d) and c:IsAbleToHand()
end
-- ①效果的发动目标：选定除外区1张自己的“随风旅鸟”卡为对象，并设置回手牌和后续召唤的操作信息。
function c17827173.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c17827173.thfilter(chkc) end
	-- 发动条件检测：除外区存在至少1张满足条件的自己的“随风旅鸟”卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17827173.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给玩家显示选择提示文本“请选择要加入手牌的卡”，用于选择对象时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外区选择1张满足条件的“随风旅鸟”卡作为效果对象，并自动与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c17827173.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：该效果处理时会将对象卡加入手卡（数量1张，对象已确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：该效果处理时可能会进行鸟兽族怪兽的召唤（具体卡在效果处理时选择，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 后续召唤的筛选条件：手牌或场上的鸟兽族怪兽，且可以无视通常召唤次数限制进行通常召唤。
function c17827173.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_WINDBEAST)
end
-- ①效果处理：将对象卡加入手卡；若成功加入手卡且存在可通常召唤的鸟兽族怪兽，则询问玩家是否召唤，并选1只鸟兽族怪兽进行通常召唤（不占用通常召唤次数）。
function c17827173.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡（即除外区的“随风旅鸟”卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，将其加入手卡成功且该卡现在位于手卡时，才继续后续召唤处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 检查手牌或场上是否存在至少1只可以通常召唤的鸟兽族怪兽（用于决定是否询问召唤）。
		and Duel.IsExistingMatchingCard(c17827173.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 若满足条件，则询问玩家“是否把鸟兽族怪兽召唤？”。
		and Duel.SelectYesNo(tp,aux.Stringid(17827173,2)) then  --"是否把鸟兽族怪兽召唤？"
		-- 中断当前效果处理，使后续的召唤处理视为在不同时点进行（避免错过时点）。
		Duel.BreakEffect()
		-- 洗切玩家手牌，因为刚刚有卡加入手牌，需要随机化手牌顺序。
		Duel.ShuffleHand(tp)
		-- 显示选择提示“请选择要召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 从手牌或场上选择1只满足召唤条件的鸟兽族怪兽作为要通常召唤的卡。
		local sg=Duel.SelectMatchingCard(tp,c17827173.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 让玩家tp以不占用通常召唤次数的方式，将选择的鸟兽族怪兽通常召唤。
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	end
end
-- ③效果的发动条件：有鸟兽族怪兽被召唤成功，且该怪兽的控制者是效果发动方（自己）。
function c17827173.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsRace(RACE_WINDBEAST)
end
-- ③效果的发动目标：确认除外区的这张卡能够加入手卡，并设置回手牌的操作信息。
function c17827173.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：该效果处理时将除外区的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果处理：若这张卡仍与效果关联，则将其从除外区加入手卡。
function c17827173.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将除外区的这张卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
