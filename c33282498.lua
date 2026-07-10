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
-- 检测这张卡是否从墓地移动到当前位置（即是否从墓地特殊召唤成功）
function c33282498.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤对方场上表侧表示且可以除外的魔法·陷阱卡
function c33282498.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果①的发动确认与除外操作的目标卡片信息设置
function c33282498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1张满足过滤条件的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33282498.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有满足过滤条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理中的操作信息为除外这些卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的实际效果处理：除外对方的魔法·陷阱卡，并根据除外卡片数量提升自身的攻击力与守备力
function c33282498.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段，获取对方场上所有满足过滤条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c33282498.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因将获取的魔法·陷阱卡以表侧表示除外，并记录实际除外的卡片数量
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
-- 在送入墓地时注册标识效果，设置持续两个回合的终了阶段，以便在下个回合的准备阶段检测该状态
function c33282498.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33282498,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 检测当前回合是否为送去墓地的下个回合，且该卡是否存在送去墓地的标记
function c33282498.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回判断结果：当前回合数不等于被送去墓地时的回合数（即下个回合），且具有送去墓地标记
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(33282498)>0
end
-- 过滤自己墓地中除「弧光勇烈龙」以外、等级为7或8的龙族怪兽，且该怪兽可以被特殊召唤
function c33282498.spfilter(c,e,tp)
	return c:IsLevel(7,8) and not c:IsCode(33282498) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动确认与取对象处理（包含对已有选择对象的合法性验证与检查自身场上怪兽区域是否有空位）
function c33282498.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33282498.spfilter(chkc,e,tp) end
	-- 在发动阶段，检查当前玩家的主怪兽区域是否存在可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地中存在至少1只可以作为效果目标的怪兽
		and Duel.IsExistingTarget(c33282498.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在客户端中显示提示信息，指导玩家选择需要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在自己墓地中选择1只满足条件的龙族怪兽作为特殊召唤的锁定对象
	local g=Duel.SelectTarget(tp,c33282498.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息为将锁定的卡片特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的实际效果处理：获取锁定的卡片，若其仍与此效果相关联，则将其在自己场上以表侧表示特殊召唤
function c33282498.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果所锁定的第一对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
