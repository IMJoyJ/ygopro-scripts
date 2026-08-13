--フルアクティブ・デュプレックス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己墓地把2只连接怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：连接状态的自己怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡被送去墓地的场合，以自己场上1只电子界族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 初始化函数：为这张卡依次注册三个效果——②的场地永续效果（连接状态的己方怪兽额外攻击1次，合计最多2次）、①的手卡特召起动效果（除外2只墓地连接怪兽后从手卡特殊召唤）、③的送墓时以自己场上1只电子界族怪兽为对象上升1000攻击力的诱发效果。
function s.initial_effect(c)
	-- ②：连接状态的自己怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果的对象筛选条件：只有处于连接状态的我方怪兽才适用这额外的攻击次数。
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
-- 定义①的代价筛选函数：选择自己墓地中的连接怪兽，且该怪兽可以作为代价被除外。
function s.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- ①的代价处理：发动前检查墓地是否有2张符合条件的连接怪兽；发动时玩家选择2张，并以表侧表示除外作为代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价发动条件检查：自己墓地中是否存在至少2张满足条件的连接怪兽（可以除外作为代价）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2张满足条件的连接怪兽，作为发动①的代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张连接怪兽以表侧表示除外，完成代价支付（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①的发动条件判断：确认自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有可用的空格，以保证这张卡有特殊召唤的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：标明本效果将特殊召唤1只怪兽（这张卡），供其他连锁效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡在手卡且仍与发动的效果保持关联后，将其以表侧攻击表示特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 定义③的取对象筛选条件：自己场上表侧表示的电子界族怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- ③的发动目标选择：以自己场上1只表侧表示的电子界族怪兽为对象发动，并设置对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否存在至少1只自己场上表侧表示的电子界族怪兽，以满足③的发动条件。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择提示：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的电子界族怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ③的效果处理：为对象怪兽赋予攻击力上升1000的效果，该效果在怪兽离场、翻面等标准重置条件下解除。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动③时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
