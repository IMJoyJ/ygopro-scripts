--カラクリ大権現 無零武
-- 效果：
-- 调整＋调整以外的机械族怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。从卡组把1只「机巧」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己的守备表示怪兽不会被战斗破坏。
-- ③：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c25904894.initial_effect(c)
	-- 为这张卡添加同调召唤手续：1只调整（任意）＋1只以上调整以外的机械族怪兽，作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_MACHINE),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从卡组把1只「机巧」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25904894,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c25904894.spcon)
	e1:SetTarget(c25904894.sptg)
	e1:SetOperation(c25904894.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己的守备表示怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 将②效果的作用对象限定为守备表示怪兽，以保护己方守备表示怪兽不被战斗破坏。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsDefensePos))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25904894,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c25904894.rmcon)
	e3:SetTarget(c25904894.rmtg)
	e3:SetOperation(c25904894.rmop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡是以同调召唤方式成功特殊召唤（召唤类型为同调召唤）时才满足。
function c25904894.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选可特殊召唤的卡：拥有「机巧」字段，并且能够被效果特殊召唤（同时检查其召唤条件与苏生限制）。
function c25904894.spfilter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动合法性检查与目标选择函数：在发动时确认己方怪兽区域有空位，且卡组中存在符合spfilter条件的「机巧」怪兽。
function c25904894.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查己方主要怪兽区域是否有空闲位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1张符合spfilter条件的「机巧」怪兽；两者同时满足才允许发动。
		and Duel.IsExistingMatchingCard(c25904894.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次操作信息为“从卡组特殊召唤1只怪兽”，供连锁判定和时点提示使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只符合条件的「机巧」怪兽，以表侧攻击表示特殊召唤到己方场上。
function c25904894.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查己方主要怪兽区域是否有空位，没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示“请选择要特殊召唤的卡”，让玩家准备进行卡牌选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从己方卡组选择1张符合条件的「机巧」怪兽（spfilter）作为特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,c25904894.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧攻击表示特殊召唤到己方场上，不设置额外召唤类型，并正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选发生表示形式变更的「机巧」怪兽：己方场上表侧攻击表示与表侧守备表示之间互相转换的「机巧」怪兽。
function c25904894.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and c:IsControler(tp) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- ③效果的发动条件：在表示形式变更的怪兽集合中，存在至少1只满足cfilter条件的己方「机巧」怪兽。
function c25904894.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25904894.cfilter,1,nil,tp)
end
-- ③效果的发动的合法性检查与取对象：确认对方场上有能除外的卡，然后选择其中1张作为效果对象并登记除外信息。
function c25904894.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动时（chk==0）检查对方场上是否存在至少1张能被除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示“请选择要除外的卡”，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1张能被除外的卡，并将该卡设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次操作信息登记为除外1张对象卡（CATEGORY_REMOVE），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果处理：若对象卡仍与效果相关，则将其从游戏中除外（表侧表示）。
function c25904894.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的第一张对象卡（即发动时选择的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，除外的原因为效果处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
