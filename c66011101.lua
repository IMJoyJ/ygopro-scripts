--No.60 刻不知のデュガレス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以把这张卡2个超量素材取除，从以下效果选择1个发动。
-- ●自己抽2张。那之后，选自己1张手卡丢弃。下次的自己抽卡阶段跳过。
-- ●从自己墓地把1只怪兽守备表示特殊召唤。下次的自己主要阶段1跳过。
-- ●自己场上1只怪兽的攻击力直到回合结束时变成2倍。下次的自己回合的战斗阶段跳过。
function c66011101.initial_effect(c)
	-- 设置该怪兽的超量召唤手续为4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：可以把这张卡2个超量素材取除，从以下效果选择1个发动。●自己抽2张。那之后，选自己1张手卡丢弃。下次的自己抽卡阶段跳过。●从自己墓地把1只怪兽守备表示特殊召唤。下次的自己主要阶段1跳过。●自己场上1只怪兽的攻击力直到回合结束时变成2倍。下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,66011101)
	e1:SetCost(c66011101.cost)
	e1:SetTarget(c66011101.target1)
	e1:SetOperation(c66011101.operation1)
	c:RegisterEffect(e1)
end
-- 设定该怪兽的“No.”编号为60
aux.xyz_number[66011101]=60
-- 效果发动的代价：检查并取除这张卡的2个超量素材
function c66011101.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤函数：用于筛选自己墓地中可以守备表示特殊召唤的怪兽
function c66011101.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤函数：用于筛选场上表侧表示的怪兽
function c66011101.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果发动的目标处理：检查可选效果的满足情况，并让玩家选择其中一个效果发动，同时设置对应的操作信息
function c66011101.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡（用于判断选项1是否可选）
	local b1=Duel.IsPlayerCanDraw(tp,2)
	-- 检查自己场上是否有空怪兽位，且墓地中是否存在可特殊召唤的怪兽（用于判断选项2是否可选）
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c66011101.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查自己场上是否存在表侧表示的怪兽（用于判断选项3是否可选）
	local b3=Duel.IsExistingMatchingCard(c66011101.atkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家从满足条件的选项中选择一个发动
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(66011101,0)},  --"抽卡并丢弃手卡"
		{b2,aux.Stringid(66011101,1)},  --"从墓地特殊召唤"
		{b3,aux.Stringid(66011101,2)})  --"攻击力变成2倍"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
		Duel.SetTargetPlayer(tp)
		-- 设置当前连锁的对象参数为2（抽卡张数）
		Duel.SetTargetParam(2)
		-- 设置连锁的操作信息为：自己抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置连锁的操作信息为：从自己墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		-- 设置连锁的操作信息为：将场上的怪兽送去墓地（此处脚本中用于占位或分类，实际效果为改变攻击力，但设置了操作信息）
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
	end
end
-- 效果处理：根据玩家选择的选项，执行对应的抽卡丢卡、特殊召唤或攻击力翻倍处理，并注册对应的跳过阶段效果
function c66011101.operation1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 获取当前连锁设定的目标玩家和目标参数（抽卡张数）
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行抽卡，若成功抽了2张卡则继续处理
		if Duel.Draw(p,d,REASON_EFFECT)==2 then
			-- 洗切玩家的手卡
			Duel.ShuffleHand(p)
			-- 中断当前效果，使后续的丢弃手卡处理不与抽卡同时进行
			Duel.BreakEffect()
			-- 让玩家选择并丢弃1张手卡
			Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
		-- ●自己抽2张。那之后，选自己1张手卡丢弃。下次的自己抽卡阶段跳过。●从自己墓地把1只怪兽守备表示特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(1,0)
		-- 判断当前回合玩家是否为自己（用于确定跳过阶段效果的持续时间）
		if Duel.GetTurnPlayer()==tp then
			-- 将当前回合数记录在效果的Label中，以便后续判断是否在下个回合生效
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c66011101.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 向玩家注册该跳过阶段的全局效果
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		-- 检查自己场上是否有空怪兽位，若无则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1只满足特殊召唤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c66011101.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		-- ●从自己墓地把1只怪兽守备表示特殊召唤。下次的自己主要阶段1跳过。●自己场上1只怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_M1)
		e1:SetTargetRange(1,0)
		-- 判断当前回合玩家是否为自己（用于确定跳过主要阶段1效果的持续时间）
		if Duel.GetTurnPlayer()==tp then
			-- 将当前回合数记录在效果的Label中
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c66011101.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 向玩家注册该跳过主要阶段1的全局效果
		Duel.RegisterEffect(e1,tp)
	else
		local c=e:GetHandler()
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从自己场上选择1只表侧表示的怪兽
		local g=Duel.SelectMatchingCard(tp,c66011101.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- ●自己场上1只怪兽的攻击力直到回合结束时变成2倍。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		-- 下次的自己回合的战斗阶段跳过。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SKIP_BP)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		-- 判断当前回合玩家是否为自己（用于确定跳过战斗阶段效果的持续时间）
		if Duel.GetTurnPlayer()==tp then
			-- 将当前回合数记录在效果的Label中
			e2:SetLabel(Duel.GetTurnCount())
			e2:SetCondition(c66011101.skipcon)
			e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 向玩家注册该跳过战斗阶段的全局效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 阶段跳过效果的生效条件：当前回合数不等于效果注册时的回合数（即从下个回合开始生效）
function c66011101.skipcon(e)
	-- 判断当前回合数是否不等于效果注册时的回合数
	return Duel.GetTurnCount()~=e:GetLabel()
end
