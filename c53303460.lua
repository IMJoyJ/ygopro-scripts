--魔神儀－キャンドール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡存在的场合，把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-蜡烛人偶」以外的卡组1只「魔神仪」怪兽和这张卡特殊召唤。
-- ②：这张卡从卡组特殊召唤的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
function c53303460.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡在手卡存在的场合，把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-蜡烛人偶」以外的卡组1只「魔神仪」怪兽和这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53303460,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53303460)
	e1:SetCost(c53303460.spcost)
	e1:SetTarget(c53303460.sptg)
	e1:SetOperation(c53303460.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组特殊召唤的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53303460,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,53303460)
	e2:SetCondition(c53303460.thcon)
	e2:SetTarget(c53303460.thtg)
	e2:SetOperation(c53303460.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c53303460.sumlimit)
	c:RegisterEffect(e3)
end
-- 特殊召唤对象筛选：判定卡组中的怪兽必须是「魔神仪」字段、不是本卡（53303460），且能被当前效果特殊召唤。
function c53303460.filter(c,e,tp)
	return c:IsSetCard(0x117) and not c:IsCode(53303460) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 费用筛选：判定手卡中的卡为仪式魔法卡且当前处于非公开状态（用于满足展示代价）。
function c53303460.costfilter(c)
	return c:GetType()==0x82 and not c:IsPublic()
end
-- ①效果的发动代价：从手卡选择1张仪式魔法卡展示给对方玩家确认，然后洗切手卡。
function c53303460.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中是否存在至少1张可展示的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53303460.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求玩家选择一张要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡中选择1张仪式魔法卡（满足costfilter）作为展示的代价。
	local g=Duel.SelectMatchingCard(tp,c53303460.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡仪式魔法卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手卡，避免通过展示暴露手卡顺序信息。
	Duel.ShuffleHand(tp)
end
-- ①效果的发动条件判定：确认自己不受「青眼精灵龙」效果影响、场上可用怪兽区至少2个、此卡本身可特殊召唤，且卡组存在符合条件的「魔神仪」怪兽。
function c53303460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己的主要怪兽区域有至少2个空格，用于特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认卡组中存在至少1只满足filter的「魔神仪」怪兽（非本卡）可以作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c53303460.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将特殊召唤2只怪兽，来源包括手卡（此卡自身）和卡组（检索的怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果处理：在满足条件的情况下，从卡组选择1只符合条件的「魔神仪」怪兽，与这张卡一起表侧表示特殊召唤。
function c53303460.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认场上仍有至少2个可用怪兽区域，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足filter条件的「魔神仪」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c53303460.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将选出的怪兽和这张卡一起以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：判定这张卡在特殊召唤成功前所在位置是卡组（即从卡组被特殊召唤）。
function c53303460.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 检索对象筛选：卡组中的仪式魔法卡且能够加入手卡。
function c53303460.thfilter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- ②效果的发动目标判定：确认卡组中存在至少1张仪式魔法卡可检索，并设置操作信息为回手卡。
function c53303460.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段：确认卡组中存在至少1张仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53303460.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张仪式魔法卡加入手卡，并向对方展示。
function c53303460.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张仪式魔法卡作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c53303460.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的仪式魔法卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的仪式魔法卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 作为③效果的限制判定：被特殊召唤的怪兽若来自额外卡组，则禁止该特殊召唤（仅影响自己）。
function c53303460.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
