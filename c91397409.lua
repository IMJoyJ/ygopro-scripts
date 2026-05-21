--ペンギン勇者
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从卡组把1只「企鹅」怪兽里侧守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的里侧守备表示怪兽不会成为对方的效果的对象。
-- ③：对方把怪兽的效果发动时才能发动。选自己场上1只里侧守备表示的水属性怪兽变成表侧守备表示。
function c91397409.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从卡组把1只「企鹅」怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91397409,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,91397409)
	e1:SetCondition(c91397409.spcon)
	e1:SetTarget(c91397409.sptg)
	e1:SetOperation(c91397409.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的里侧守备表示怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤自己场上的里侧守备表示怪兽作为效果适用对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_FACEDOWN_DEFENSE))
	-- 设定为不会成为对方的效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：对方把怪兽的效果发动时才能发动。选自己场上1只里侧守备表示的水属性怪兽变成表侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91397409,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,91397410)
	e3:SetCondition(c91397409.poscon)
	e3:SetTarget(c91397409.postg)
	e3:SetOperation(c91397409.posop)
	c:RegisterEffect(e3)
end
-- 定义效果①的发动条件：这张卡同调召唤成功。
function c91397409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中可以里侧守备表示特殊召唤的「企鹅」怪兽。
function c91397409.spfilter(c,e,tp)
	return c:IsSetCard(0x5a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 定义效果①的发动准备（检查怪兽区域空位以及卡组中是否存在可特召的「企鹅」怪兽）。
function c91397409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的「企鹅」怪兽。
		and Duel.IsExistingMatchingCard(c91397409.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果①的实际处理：从卡组将1只「企鹅」怪兽里侧守备表示特殊召唤。
function c91397409.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息：选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「企鹅」怪兽。
	local g=Duel.SelectMatchingCard(tp,c91397409.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义效果③的发动条件：此卡不在战斗破坏状态，且对方发动了怪兽的效果。
function c91397409.poscon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己场上可以改变表示形式的里侧守备表示水属性怪兽。
function c91397409.posfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanChangePosition()
end
-- 定义效果③的发动准备（检查自己场上是否存在可改变表示形式的里侧守备表示水属性怪兽）。
function c91397409.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的里侧守备表示水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c91397409.posfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义效果③的实际处理：选自己场上1只里侧守备表示的水属性怪兽变成表侧守备表示。
function c91397409.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择自己场上1只满足条件的里侧守备表示水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c91397409.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为选中的怪兽显示被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 将选中的怪兽变成表侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
