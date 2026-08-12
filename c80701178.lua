--魔神儀－タリスマンドラ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡存在的场合，把手卡1只仪式怪兽给对方观看才能发动。「魔神仪-曼德拉护符草」以外的卡组1只「魔神仪」怪兽和这张卡特殊召唤。
-- ②：这张卡从卡组特殊召唤的场合才能发动。从卡组把1只仪式怪兽加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
function c80701178.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，把手卡1只仪式怪兽给对方观看才能发动。「魔神仪-曼德拉护符草」以外的卡组1只「魔神仪」怪兽和这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80701178,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,80701178)
	e1:SetCost(c80701178.spcost)
	e1:SetTarget(c80701178.sptg)
	e1:SetOperation(c80701178.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组特殊召唤的场合才能发动。从卡组把1只仪式怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80701178,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,80701178)
	e2:SetCondition(c80701178.thcon)
	e2:SetTarget(c80701178.thtg)
	e2:SetOperation(c80701178.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c80701178.sumlimit)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「魔神仪-曼德拉护符草」以外且可以特殊召唤的「魔神仪」怪兽
function c80701178.filter(c,e,tp)
	return c:IsSetCard(0x117) and not c:IsCode(80701178) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤手卡中未给对方观看的仪式怪兽
function c80701178.costfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and not c:IsPublic()
end
-- ①号效果的发动代价：将手卡1只仪式怪兽给对方观看
function c80701178.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手卡是否存在可以给对方观看的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80701178.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置选择提示信息为“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c80701178.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的仪式怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
end
-- ①号效果的发动准备：检查是否能同时特殊召唤自身和卡组的「魔神仪」怪兽，并设置特殊召唤的操作信息
function c80701178.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在可以特殊召唤的「魔神仪」怪兽
		and Duel.IsExistingMatchingCard(c80701178.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从手卡和卡组特殊召唤共2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①号效果的处理：从卡组选择1只「魔神仪」怪兽，与手卡的这张卡一起特殊召唤
function c80701178.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的主要怪兽区域空位不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 设置选择提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特殊召唤条件的「魔神仪」怪兽
	local g=Duel.SelectMatchingCard(tp,c80701178.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将选中的怪兽（包含这张卡和卡组选出的怪兽）以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动条件：检查这张卡是否是从卡组特殊召唤
function c80701178.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 过滤卡组中可以加入手卡的仪式怪兽
function c80701178.thfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- ②号效果的发动准备：检查卡组是否存在仪式怪兽，并设置检索的操作信息
function c80701178.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在可以加入手卡的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80701178.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理：从卡组选择1只仪式怪兽加入手卡，并给对方确认
function c80701178.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示信息为“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c80701178.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽通过效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③号效果的限制条件：限制特殊召唤的怪兽来源为额外卡组
function c80701178.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
