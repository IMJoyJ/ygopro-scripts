--ビーストライザー
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的兽族·兽战士族怪兽除外，以自己场上1只兽族·兽战士族怪兽为对象才能发动。那只自己的兽族·兽战士族怪兽的攻击力上升因为这个效果发动而除外的怪兽的原本攻击力数值。
function c84962466.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上1只表侧表示的兽族·兽战士族怪兽除外，以自己场上1只兽族·兽战士族怪兽为对象才能发动。那只自己的兽族·兽战士族怪兽的攻击力上升因为这个效果发动而除外的怪兽的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84962466,1))  --"攻击上升"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	-- 设置效果发动条件：在伤害步骤中，仅在伤害计算前可以发动（利用aux.dscon辅助函数过滤掉伤害计算后）。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c84962466.cost)
	e2:SetTarget(c84962466.target)
	e2:SetOperation(c84962466.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件（用于作为Cost除外的怪兽）：自己场上表侧表示的兽族或兽战士族怪兽，且该怪兽可以作为Cost除外，并且场上还存在至少1只其他可以作为效果对象的兽族或兽战士族怪兽。
function c84962466.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR) and c:IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在至少1只除了当前作为Cost候选的怪兽以外、可以作为效果对象的兽族或兽战士族怪兽。
		and Duel.IsExistingTarget(c84962466.filter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤条件（用于作为效果对象的怪兽）：自己场上表侧表示的兽族或兽战士族怪兽。
function c84962466.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 效果发动代价（Cost）处理函数：检查并执行将自己场上1只表侧表示的兽族·兽战士族怪兽除外的操作，并记录其原本攻击力。
function c84962466.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：判断自己场上是否存在满足Cost除外条件且有合法选择对象的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c84962466.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给玩家发送提示信息：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只满足Cost条件的自己场上的兽族或兽战士族怪兽。
	local rg=Duel.SelectMatchingCard(tp,c84962466.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabel(rg:GetFirst():GetBaseAttack())
	-- 将选择的怪兽作为发动代价（Cost）表侧表示除外。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 效果目标（Target）处理函数：选择自己场上1只表侧表示的兽族·兽战士族怪兽作为效果对象。
function c84962466.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c84962466.filter(chkc) end
	if chk==0 then return e:IsCostChecked() end
	-- 给玩家发送提示信息：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的兽族或兽战士族怪兽作为效果对象。
	Duel.SelectTarget(tp,c84962466.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果运行（Operation）处理函数：使作为对象的怪兽攻击力上升被除外怪兽的原本攻击力数值。
function c84962466.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只自己的兽族·兽战士族怪兽的攻击力上升因为这个效果发动而除外的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
