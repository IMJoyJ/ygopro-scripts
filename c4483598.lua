--フルアクティブ・デュプレックス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己墓地把2只连接怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：连接状态的自己怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡被送去墓地的场合，以自己场上1只电子界族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 注册三个效果：②连接怪兽可额外攻击1次、①从墓地除外2只连接怪兽特殊召唤、③被送去墓地时场上电子界族怪兽攻击力上升1000
function s.initial_effect(c)
	-- ②连接状态的自己怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为处于连接状态的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLinkState))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把2只连接怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己场上1只电子界族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断是否为连接怪兽且可作为除外的费用
function s.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- 费用处理函数：检查是否满足除外2只连接怪兽的条件并选择除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外2只连接怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤的发动条件判断：检查是否有空场和卡是否可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有空场
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤的处理函数：将卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否还在场上并执行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤函数：判断是否为表侧表示的电子界族怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 效果对象选择函数：选择场上一只表侧表示的电子界族怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的一只怪兽作为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：使对象怪兽攻击力上升1000
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给对象怪兽增加1000攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
