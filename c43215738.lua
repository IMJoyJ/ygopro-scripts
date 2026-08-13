--メメント・フラクチャー・ダンス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「莫忘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，可以把场上1张卡破坏。
-- ②：自己的「莫忘」怪兽和对方怪兽进行战斗的攻击宣言时，把墓地的这张卡除外才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
local s,id,o=GetID()
-- 为「莫忘骨折舞」注册两个效果：①发动后以场上1张卡为对象破坏，若场上有「冥骸合龙-莫忘冥地王灵」则再追加破坏1张；②攻击宣言时从墓地除外自身，使对方全部怪兽攻击力下降1000。
function s.initial_effect(c)
	-- ①：自己场上有「莫忘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，可以把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「莫忘」怪兽和对方怪兽进行战斗的攻击宣言时，把墓地的这张卡除外才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 设置②效果的发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：表侧表示且属于「莫忘」系列（SetCard 0x1a1）的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- ①效果的发动条件：自己场上存在表侧表示的「莫忘」怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「莫忘」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时的目标选择处理：选择场上1张卡作为对象（不能选择本卡），并设置破坏的操作信息，供连锁检测。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 发动合法性检查：确认场上存在可以成为对象的卡（不包括本卡）。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 弹出提示消息，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡作为对象（不能选本卡），并登记为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息：本次效果将破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义筛选条件：表侧表示且卡号为23288411（冥骸合龙-莫忘冥地王灵）。
function s.filter(c)
	return c:IsFaceup() and c:IsCode(23288411)
end
-- ①效果处理：取对象卡，若对象仍与效果关联则将其破坏；若破坏成功且自己场上有「冥骸合龙-莫忘冥地王灵」才继续后续追加破坏，否则终止。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联（未离场/未失效），并对其执行破坏；若破坏失败则终止。
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)<1
		-- 追加检查：自己场上是否存在「冥骸合龙-莫忘冥地王灵」，不存在则不能进行追加破坏。
		or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 取得场上除本卡以外所有卡的集合，用于追加破坏的选择（用aux.ExceptThisCard排除本卡）。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 若存在可选破坏的卡且玩家选择“是”，则进行追加破坏处理。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否破坏场上1张卡？"
		-- 弹出提示消息，让玩家选择要追加破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 手动显示所选卡的对象动画，并记录这些卡被选为对象。
		Duel.HintSelection(sg)
		-- 中断当前效果处理，使之后的破坏视为不同时处理，避免错失时点。
		Duel.BreakEffect()
		-- 将选择的卡以效果破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：自己的「莫忘」怪兽和对方怪兽进行战斗的攻击宣言时，且我方攻击怪兽为表侧表示「莫忘」，对方存在战斗对象。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方正参与战斗的怪兽。
	local a=Duel.GetBattleMonster(tp)
	if not a then return false end
	local d=a:GetBattleTarget()
	return a:IsFaceup() and a:IsSetCard(0x1a1) and d and d:IsControler(1-tp)
end
-- ②效果处理：将对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降1000。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的全部表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上的每只表侧表示怪兽，逐只赋予攻击力下降效果。
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
	end
end
