--カラクリ大権現 無零武
-- 效果：
-- 调整＋调整以外的机械族怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。从卡组把1只「机巧」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己的守备表示怪兽不会被战斗破坏。
-- ③：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c25904894.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的机械族怪兽作为素材
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
	-- 设置效果目标为守备表示的怪兽
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
-- 效果发动条件：确认此卡为同调召唤成功
function c25904894.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的「机巧」怪兽，用于特殊召唤
function c25904894.spfilter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件：场上存在空位且卡组存在满足条件的怪兽
function c25904894.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c25904894.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：从卡组选择1只「机巧」怪兽特殊召唤
function c25904894.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25904894.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的「机巧」怪兽，用于表示形式变更检测
function c25904894.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and c:IsControler(tp) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- 效果发动条件：确认场上存在表示形式变更的「机巧」怪兽
function c25904894.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25904894.cfilter,1,nil,tp)
end
-- 设置除外效果的目标选择条件：对方场上的1张可除外的卡
function c25904894.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作：将目标卡除外
function c25904894.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
