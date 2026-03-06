--剣闘獣サムニテ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「剑斗兽」的卡加入手卡。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 盾斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c2619149.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「剑斗兽」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2619149,0))  --"检索卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c2619149.scon)
	e1:SetTarget(c2619149.stg)
	e1:SetOperation(c2619149.sop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 盾斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2619149,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2619149.spcon)
	e2:SetCost(c2619149.spcost)
	e2:SetTarget(c2619149.sptg)
	e2:SetOperation(c2619149.spop)
	c:RegisterEffect(e2)
end
-- 效果作用：判断是否为通过「剑斗兽」怪兽效果特殊召唤成功且满足战斗破坏条件
function c2619149.scon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前怪兽是否为通过「剑斗兽」怪兽效果特殊召唤成功且满足战斗破坏对方怪兽的条件
	return c:GetFlagEffect(2619149)>0 and aux.bdogcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤函数：筛选卡组中名字带有「剑斗兽」且可以加入手牌的卡
function c2619149.sfilter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToHand()
end
-- 效果作用：设置检索满足条件的卡组卡片
function c2619149.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张名字带有「剑斗兽」且可以加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2619149.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 效果作用：执行检索并加入手牌
function c2619149.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组卡片
	local g=Duel.SelectMatchingCard(tp,c2619149.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果作用：判断是否满足特殊召唤条件
function c2619149.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果作用：设置特殊召唤的代价
function c2619149.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将自身送入卡组并洗牌作为特殊召唤的代价
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：筛选卡组中除「剑斗兽 盾斗」外名字带有「剑斗兽」且可以特殊召唤的怪兽
function c2619149.filter(c,e,tp)
	return not c:IsCode(2619149) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置特殊召唤满足条件的怪兽
function c2619149.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件：场上是否有空位且卡组中是否存在至少1张名字带有「剑斗兽」且可以特殊召唤的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断是否满足特殊召唤条件：卡组中是否存在至少1张名字带有「剑斗兽」且可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c2619149.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤
function c2619149.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡组卡片
	local g=Duel.SelectMatchingCard(tp,c2619149.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
