--バスター・リッチー
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1只有「爆裂模式」的卡名记述的怪兽或者4星以下的不死族怪兽特殊召唤。
-- ②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「爆裂斩」或「爆裂反击」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①召唤·特殊召唤成功时从墓地特召怪兽、②作为同调素材时可当作非调整、③作为同调素材送墓时检索「爆裂斩」或「爆裂反击」的效果。
function s.initial_effect(c)
	-- 将「爆裂模式」（80280737）、「爆裂斩」（40012727）、「爆裂反击」（76407432）登记为此卡效果文本中记载的卡片密码。
	aux.AddCodeList(c,80280737,40012727,76407432)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1只有「爆裂模式」的卡名记述的怪兽或者4星以下的不死族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetValue(s.tnval)
	c:RegisterEffect(e3)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「爆裂斩」或「爆裂反击」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检索自己墓地中满足“有「爆裂模式」卡名记述的怪兽”或“4星以下的不死族怪兽”且能特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	-- 检查卡片是否记载有「爆裂模式」或者为4星以下的不死族怪兽，并且该卡可以被特殊召唤。
	return (aux.IsCodeListed(c,80280737) or (c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）函数，检查怪兽区域空位以及墓地中是否存在可特召的合法目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件（chk==0）：检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1张满足特召过滤条件的卡。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从自己墓地特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的效果处理（Operation）函数，执行从墓地特殊召唤怪兽的操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的主要怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足特召条件且不受「王家之谷」影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的数值函数，限制只有在自己场上作为同调素材时，才能将此卡当作非调整怪兽使用。
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- 效果③的发动条件函数，检查此卡是否作为同调素材被送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数：检索卡组中卡名为「爆裂斩」或「爆裂反击」且能加入手牌的卡。
function s.filter(c)
	return c:IsCode(40012727,76407432) and c:IsAbleToHand()
end
-- 效果③的发动准备（Target）函数，检查卡组中是否存在可检索的目标并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件（chk==0）：检查自己卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（Operation）函数，执行从卡组检索「爆裂斩」或「爆裂反击」的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
