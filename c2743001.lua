--水晶機巧－フェニキシオン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。对方的场上·墓地的魔法·陷阱卡全部除外。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c2743001.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的同调怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。对方的场上·墓地的魔法·陷阱卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2743001,0))  --"场上·墓地魔陷除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c2743001.rmcon)
	e1:SetTarget(c2743001.rmtg)
	e1:SetOperation(c2743001.rmop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2743001,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c2743001.spcon)
	e2:SetTarget(c2743001.sptg)
	e2:SetOperation(c2743001.spop)
	c:RegisterEffect(e2)
end
c2743001.material_type=TYPE_SYNCHRO
-- 判断此卡是否为同调召唤
function c2743001.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的魔法·陷阱卡，且可除外
function c2743001.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 检索满足条件的魔法·陷阱卡组，用于除外
function c2743001.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2743001.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 获取满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c2743001.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行除外操作
function c2743001.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c2743001.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断此卡是否为同调召唤且被战斗或效果破坏
function c2743001.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤满足条件的可特殊召唤怪兽
function c2743001.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索满足条件的怪兽组，用于特殊召唤
function c2743001.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2743001.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c2743001.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择特殊召唤的目标怪兽
	local g=Duel.SelectTarget(tp,c2743001.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c2743001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
