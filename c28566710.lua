--ラストバトル！
-- 效果：
-- 自己的基本分1000分以下时，在对方的回合才能发动。选择自己的场上的1只怪兽，双方的其他的场上和手上的卡全部送去墓地。之后，对方从卡组选择1只怪兽攻击表示特殊召唤并进行战斗（玩家的战斗伤害为0）。回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局。
function c28566710.initial_effect(c)
	-- 效果定义：魔陷发动，特殊召唤类别，自由时点，准备阶段时点，满足条件时才能发动，选择目标，进行处理
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCondition(c28566710.condition)
	e1:SetTarget(c28566710.target)
	e1:SetOperation(c28566710.operation)
	c:RegisterEffect(e1)
end
-- 效果原文：自己的基本分1000分以下时，在对方的回合才能发动
function c28566710.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断玩家LP是否小于等于1000且当前回合不是玩家自己
	return Duel.GetLP(tp)<=1000 and Duel.GetTurnPlayer()~=tp
end
-- 效果原文：选择自己的场上的1只怪兽，双方的其他的场上和手上的卡全部送去墓地
function c28566710.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家自己场上是否存在至少1张怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 规则层面：检查对方玩家是否可以特殊召唤
		and Duel.IsPlayerCanSpecialSummon(1-tp) end
	-- 规则层面：设置操作信息，表示对方从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
end
-- 效果原文：之后，对方从卡组选择1只怪兽攻击表示特殊召唤并进行战斗（玩家的战斗伤害为0）
function c28566710.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 规则层面：提示玩家选择自己场上的1只怪兽，获取场上所有卡的集合，将选中的怪兽移出集合，将集合中的所有卡送去墓地，提示对方选择要特殊召唤的怪兽，特殊召唤对方选择的怪兽，为对方玩家添加不造成战斗伤害效果，计算战斗伤害
function c28566710.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面：选择玩家自己场上的1只怪兽
	local tg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	-- 规则层面：获取玩家自己场上和手上的所有卡
	local hg=Duel.GetFieldGroup(tp,0xe,0xe)
	if tc then hg:RemoveCard(tc) end
	-- 规则层面：将所有卡送去墓地
	Duel.SendtoGrave(hg,REASON_EFFECT)
	-- 规则层面：提示对方玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：对方从卡组选择1只怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(1-tp,c28566710.spfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc then
		-- 规则层面：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面：将对方选择的怪兽特殊召唤到对方场上
		Duel.SpecialSummon(sc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		-- 效果原文：回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_CHAIN)
		-- 规则层面：注册不造成战斗伤害效果给玩家
		Duel.RegisterEffect(e1,tp)
		-- 规则层面：计算战斗伤害
		if tc then Duel.CalculateDamage(sc,tc) end
	end
	-- 效果原文：回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c28566710.checkop)
	-- 规则层面：注册回合结束时的胜利判定效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果原文：回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局
function c28566710.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取玩家0场上怪兽数量
	local t1=Duel.GetFieldGroupCount(0,LOCATION_MZONE,0)
	-- 规则层面：获取玩家1场上怪兽数量
	local t2=Duel.GetFieldGroupCount(1,LOCATION_MZONE,0)
	if t1>0 and t2==0 then
		-- 规则层面：玩家0获胜
		Duel.Win(0,0x16)
	elseif t2>0 and t1==0 then
		-- 规则层面：玩家1获胜
		Duel.Win(1,0x16)
	else
		-- 规则层面：平局
		Duel.Win(PLAYER_NONE,0x16)
	end
end
