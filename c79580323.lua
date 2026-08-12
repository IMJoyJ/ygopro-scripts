--剣闘獣スパルティクス
-- 效果：
-- 「剑斗兽 重斗」以外的效果不能把这张卡特殊召唤。这张卡特殊召唤成功时，从卡组把1张名字带有「斗器」的装备魔法卡加入手卡。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 斯巴达克斯」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c79580323.initial_effect(c)
	-- 这张卡特殊召唤成功时，从卡组把1张名字带有「斗器」的装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79580323,0))  --"检索卡组"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c79580323.stg)
	e1:SetOperation(c79580323.sop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 斯巴达克斯」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79580323,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c79580323.spcon)
	e2:SetCost(c79580323.spcost)
	e2:SetTarget(c79580323.sptg)
	e2:SetOperation(c79580323.spop)
	c:RegisterEffect(e2)
	-- 「剑斗兽 重斗」以外的效果不能把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c79580323.splimit)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制的判定函数，仅允许通过「剑斗兽 重斗」的效果或灵摆召唤来特殊召唤
function c79580323.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(4253484) or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤卡组中名字带有「斗器」的装备魔法卡且能加入手牌的过滤条件
function c79580323.sfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 检索效果的发动准备，设置操作信息为从卡组将1张卡加入手牌
function c79580323.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表示该效果会把卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 检索效果的执行，从卡组选择1张「斗器」装备魔法卡加入手牌并给对方确认
function c79580323.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「斗器」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c79580323.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤效果的发动条件，要求这张卡在本次战斗阶段进行过战斗
function c79580323.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤效果的发动代价，将自身回到卡组
function c79580323.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将这张卡送回持有者卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤卡组中「剑斗兽 斯巴达克斯」以外、名字带有「剑斗兽」且可以特殊召唤的怪兽
function c79580323.filter(c,e,tp)
	return not c:IsCode(79580323) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽
function c79580323.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价回卡组，所以可用空位数量需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查卡组中是否存在至少1只满足条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c79580323.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行，从卡组选择1只「剑斗兽」怪兽特殊召唤到场上
function c79580323.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c79580323.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
