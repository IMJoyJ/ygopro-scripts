--メメント・フラクチャー・ダンス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「莫忘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己场上有「冥骸合龙-莫忘冥地王灵」存在的场合，可以把场上1张卡破坏。
-- ②：自己的「莫忘」怪兽和对方怪兽进行战斗的攻击宣言时，把墓地的这张卡除外才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
local s,id,o=GetID()
-- 注册两个效果，分别是①效果和②效果
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
	-- 效果的发动需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「莫忘」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 效果①的发动条件，判断自己场上是否存在「莫忘」怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在「莫忘」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时选择目标，选择场上1张卡作为破坏对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 判断是否能选择场上1张卡作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置效果操作信息，表示将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数，用于判断场上是否存在「冥骸合龙-莫忘冥地王灵」
function s.filter(c)
	return c:IsFaceup() and c:IsCode(23288411)
end
-- 效果①的发动处理，先破坏选择的卡，再判断是否满足额外破坏条件
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然在场上且成功破坏
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)<1
		-- 判断自己场上是否存在「冥骸合龙-莫忘冥地王灵」
		or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 获取场上所有满足条件的卡组成的卡片组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 判断是否有满足条件的卡且询问玩家是否破坏
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否破坏场上1张卡？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示选择的卡被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 破坏选择的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 效果②的发动条件，判断是否为自己的「莫忘」怪兽攻击对方怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的怪兽
	local a=Duel.GetBattleMonster(tp)
	if not a then return false end
	local d=a:GetBattleTarget()
	return a:IsFaceup() and a:IsSetCard(0x1a1) and d and d:IsControler(1-tp)
end
-- 效果②的发动处理，使对方场上所有怪兽攻击力下降1000
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历所有对方场上的表侧表示怪兽
	for tc in aux.Next(g) do
		-- 为每个怪兽设置攻击力下降1000的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
	end
end
