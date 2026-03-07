--アークブレイブドラゴン
-- 效果：
-- ①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示的魔法·陷阱卡全部除外，这张卡的攻击力·守备力上升这个效果除外的卡数量×200。
-- ②：这张卡被送去墓地的下个回合的准备阶段，以「弧光勇烈龙」以外的自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c33282498.initial_effect(c)
	-- ①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示的魔法·陷阱卡全部除外，这张卡的攻击力·守备力上升这个效果除外的卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c33282498.condition)
	e1:SetTarget(c33282498.target)
	e1:SetOperation(c33282498.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的下个回合的准备阶段，以「弧光勇烈龙」以外的自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c33282498.regop)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c33282498.spcon)
	e3:SetTarget(c33282498.sptg)
	e3:SetOperation(c33282498.spop)
	c:RegisterEffect(e3)
end
-- 效果原文内容
function c33282498.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤函数，检查以player来看的对方场上是否存在至少1张满足过滤条件的魔法·陷阱卡
function c33282498.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 设置当前处理的连锁的操作信息，包含要除外的魔法·陷阱卡
function c33282498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以player来看的对方场上是否存在至少1张满足过滤条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33282498.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取以player来看的对方场上满足过滤条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置当前处理的连锁的操作信息，包含要除外的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果作用
function c33282498.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以player来看的对方场上满足过滤条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以REASON_EFFECT原因，POS_FACEUP形式除外g中的卡，返回实际被除外的数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个攻击力提升效果，提升值为除外卡数量×200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*200)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- 效果作用
function c33282498.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33282498,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 效果原文内容
function c33282498.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前回合是否不是该卡进入墓地的回合，并且该卡拥有标记
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(33282498)>0
end
-- 过滤函数，检查以player来看的自己墓地是否存在至少1张满足过滤条件的7·8星龙族怪兽
function c33282498.spfilter(c,e,tp)
	return c:IsLevel(7,8) and not c:IsCode(33282498) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置当前处理的连锁的操作信息，包含要特殊召唤的怪兽
function c33282498.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33282498.spfilter(chkc,e,tp) end
	-- 检查以player来看的自己场上是否存在至少1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查以player来看的自己墓地是否存在至少1张满足过滤条件的7·8星龙族怪兽
		and Duel.IsExistingTarget(c33282498.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足过滤条件的1只怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c33282498.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前处理的连锁的操作信息，包含要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用
function c33282498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以0方式将tc特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
