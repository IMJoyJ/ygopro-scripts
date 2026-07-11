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
	-- ②：这张卡被送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c33282498.regop)
	c:RegisterEffect(e2)
	-- 的下个回合的准备阶段，以「弧光勇烈龙」以外的自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 效果①的发动条件：此卡从墓地特殊召唤成功
function c33282498.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤对方场上表侧表示且可以除外的魔法、陷阱卡
function c33282498.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果①的发动目标检查与操作信息设置：检查对方场上是否存在可除外的表侧表示魔陷，并收集这些卡片设置除外操作信息
function c33282498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以除外的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33282498.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以除外的表侧表示魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息：除外对方场上所有符合条件的魔陷卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的处理：除外对方场上表侧表示的魔陷卡，并根据除外数量上升此卡的攻击力和守备力
function c33282498.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以除外的表侧表示魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果除外目标卡片，并获取实际除外的卡片数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力·守备力上升这个效果除外的卡数量×200。
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
-- 在此卡被送去墓地时注册标识，用于判断下个回合的准备阶段是否可以发动特殊召唤效果
function c33282498.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33282498,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 效果②的发动条件：当前回合不是送去墓地的回合，且此卡存有送墓时的标识（即下个回合的准备阶段）
function c33282498.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认当前不是送墓的回合，且此卡仍持有送墓时注册的标识
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(33282498)>0
end
-- 过滤自己墓地中除「弧光勇烈龙」以外的7·8星龙族怪兽
function c33282498.spfilter(c,e,tp)
	return c:IsLevel(7,8) and not c:IsCode(33282498) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标检查与取对象：检查怪兽区域是否有空位、自己墓地是否存在符合条件的龙族怪兽，并选择其作为特殊召唤的对象
function c33282498.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33282498.spfilter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地中存在符合条件的特殊召唤对象怪兽
		and Duel.IsExistingTarget(c33282498.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择需要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的龙族怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c33282498.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息：特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：将选择的对象怪兽在自己场上表侧表示特殊召唤
function c33282498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
