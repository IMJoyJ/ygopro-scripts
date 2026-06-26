--アークブレイブドラゴン
-- 效果：
-- ①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示的魔法·陷阱卡全部除外，这张卡的攻击力·守备力上升这个效果除外的卡数量×200。
-- ②：这张卡被送去墓地的下个回合的准备阶段，以「弧光勇烈龙」以外的自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c33282498.initial_effect(c)
	-- ①：这张卡从墓地特殊召唤成功的场合才能发动。对方场上的表侧表示的魔法·陷阱卡全部除外，这张卡的攻击力·守备力上升这个效果除外的卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c33282498.condition)
	e1:SetTarget(c33282498.target)
	e1:SetOperation(c33282498.operation)
	c:RegisterEffect(e1)
	-- 这卡被送去墓地的场合注册标记效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c33282498.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的下个回合的准备阶段，以「弧光勇烈龙」以外的自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 检查是否从墓地特殊召唤成功
function c33282498.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤对方场上表侧表示的且可除外的魔法·陷阱卡
function c33282498.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 除外效果发动的可行性检测与操作设置
function c33282498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可除外的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33282498.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有符合条件的表侧表示魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息为除外对方场上的这些卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 除外效果操作执行与攻击力·守备力上升效果处理
function c33282498.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有符合条件的表侧表示魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将选中的卡片除外，并获取除外的卡片数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力·守备力上升这个效果除外的卡数量×200
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
-- 当被送去墓地时，在自身上注册一个持续到下个回合结束的Flag效果
function c33282498.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33282498,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 特殊召唤效果的发动条件判定（不是被送去墓地的当回合，且有注册的Flag标记存在）
function c33282498.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前回合是否非被送去墓地的回合，且卡片带有标记效果
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(33282498)>0
end
-- 过滤自己墓地中符合条件的7·8星龙族怪兽（非自身且可特招）
function c33282498.spfilter(c,e,tp)
	return c:IsLevel(7,8) and not c:IsCode(33282498) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的对象选择与操作设置
function c33282498.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33282498.spfilter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在符合条件的7·8星龙族怪兽
		and Duel.IsExistingTarget(c33282498.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中符合条件的一只7·8星龙族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c33282498.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的操作执行
function c33282498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的对象怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
