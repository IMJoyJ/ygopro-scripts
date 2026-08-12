--ハイパーブレイズ
-- 效果：
-- ①：「神炎皇 乌利亚」用自身的方法特殊召唤的场合，也能把自己场上的里侧表示的陷阱卡送去墓地。
-- ②：自己的「神炎皇 乌利亚」进行战斗的攻击宣言时1次，从手卡·卡组把1张陷阱卡送去墓地才能发动。这个回合，那只怪兽的攻击力·守备力变成双方的场上·墓地的陷阱卡数量×1000。
-- ③：1回合1次，丢弃1张手卡才能发动。从自己墓地选「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只加入手卡或无视召唤条件特殊召唤。
function c16317140.initial_effect(c)
	-- 记录该卡与「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的关联
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的「神炎皇 乌利亚」进行战斗的攻击宣言时1次，从手卡·卡组把1张陷阱卡送去墓地才能发动。这个回合，那只怪兽的攻击力·守备力变成双方的场上·墓地的陷阱卡数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(16317140)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- 改变攻击力·守备力
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16317140,0))  --"改变攻击力·守备力"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c16317140.atkcon)
	e3:SetCost(c16317140.atkcost)
	e3:SetOperation(c16317140.atkop)
	c:RegisterEffect(e3)
	-- 加入手卡或特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16317140,1))  --"加入手卡或特殊召唤"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c16317140.spcost)
	e4:SetTarget(c16317140.sptg)
	e4:SetOperation(c16317140.spop)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的陷阱卡（可送去墓地作为费用）
function c16317140.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 过滤满足条件的陷阱卡（场上或墓地的陷阱卡）
function c16317140.tpfilter(c)
	return c:IsType(TYPE_TRAP) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 判断攻击宣言是否由己方的「神炎皇 乌利亚」发起
function c16317140.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(a)
	return a and a:IsCode(6007213) and a:IsFaceup() and a:IsControler(tp)
end
-- 过滤满足条件的陷阱卡（可送去墓地作为费用）
function c16317140.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：己方手卡或卡组存在陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16317140.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c16317140.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将所选陷阱卡送去墓地
	Duel.SendtoGrave(g:GetFirst(),REASON_COST)
end
-- 设置攻击力和守备力变化效果
function c16317140.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 计算双方场上和墓地的陷阱卡数量并乘以1000
		local val=Duel.GetMatchingGroupCount(c16317140.tpfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)*1000
		if val==0 then return end
		-- 设置攻击变化效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(val)
		tc:RegisterEffect(e1)
		-- 设置守备力变化效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(val)
		tc:RegisterEffect(e2)
	end
end
-- 过滤满足条件的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
function c16317140.spfilter(c,e,tp)
	return c:IsCode(32491822,6007213,69890967)
		-- 判断是否可以特殊召唤或加入手卡
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
-- 检查是否满足条件：己方手卡存在可丢弃的卡
function c16317140.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：己方手卡存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张手卡作为费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果处理时的操作信息
function c16317140.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：己方墓地存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16317140.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置将卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置将卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理效果选择卡并决定加入手卡或特殊召唤
function c16317140.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择满足条件的卡
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16317140.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	if sc then
		-- 判断是否满足条件：己方场上存在空位且该卡可特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,true,false)
			-- 判断是否满足条件：选择特殊召唤或加入手卡
			and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将所选卡特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
		else
			-- 将所选卡加入手卡
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
		end
	end
end
