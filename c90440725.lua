--サイバー・シャドー・ガードナー
-- 效果：
-- 对方的主要阶段时才能发动。这张卡发动后变成怪兽卡（机械族·地·4星·攻/守?）在自己的怪兽卡区域特殊召唤。这张卡为攻击对象的对方怪兽的攻击宣言时，这张卡的攻击力·守备力变成和对方攻击怪兽相同数值。这张卡在对方的结束阶段时在魔法与陷阱卡区域盖放。这张卡也当作陷阱卡使用。
function c90440725.initial_effect(c)
	-- 对方的主要阶段时才能发动。这张卡发动后变成怪兽卡（机械族·地·4星·攻/守?）在自己的怪兽卡区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c90440725.condition)
	e1:SetTarget(c90440725.target)
	e1:SetOperation(c90440725.activate)
	c:RegisterEffect(e1)
	-- 这张卡为攻击对象的对方怪兽的攻击宣言时，这张卡的攻击力·守备力变成和对方攻击怪兽相同数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c90440725.atkcon)
	e2:SetOperation(c90440725.atkop)
	c:RegisterEffect(e2)
	-- 这张卡在对方的结束阶段时在魔法与陷阱卡区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90440725,0))  --"魔陷区盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c90440725.setcon)
	e3:SetTarget(c90440725.settg)
	e3:SetOperation(c90440725.setop)
	c:RegisterEffect(e3)
end
-- 定义发动条件函数：判定是否在对方的主要阶段
function c90440725.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前回合玩家是否为对方，且当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==1-tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义发动靶向函数：检查怪兽区域空位以及是否能将此卡作为怪兽特殊召唤，并设置特殊召唤的操作信息
function c90440725.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自身的主要怪兽区域是否有空余位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为特定属性、种族、等级的怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,90440725,0,TYPES_EFFECT_TRAP_MONSTER,-2,-2,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义发动效果处理函数：将此卡作为怪兽特殊召唤
function c90440725.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否能将此卡作为怪兽特殊召唤，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,90440725,0,TYPES_EFFECT_TRAP_MONSTER,-2,-2,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 定义攻击宣言时效果的触发条件函数：判定此卡是否由自身效果特招，且被对方怪兽选为攻击对象
function c90440725.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定此卡是通过自身效果特殊召唤，且攻击怪兽的控制者为对方，且攻击对象为此卡
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==c
end
-- 定义攻击宣言时效果的处理函数：将此卡的攻击力、守备力变成和对方攻击怪兽相同数值
function c90440725.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力·守备力变成和对方攻击怪兽相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	-- 将攻击力设定为攻击怪兽的当前攻击力
	e1:SetValue(Duel.GetAttacker():GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力·守备力变成和对方攻击怪兽相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	-- 将守备力设定为攻击怪兽的当前守备力
	e1:SetValue(Duel.GetAttacker():GetDefense())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 定义结束阶段效果的触发条件函数：判定此卡是否由自身效果特招，且当前为对方回合
function c90440725.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定此卡是通过自身效果特殊召唤，且当前回合玩家为对方
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and Duel.GetTurnPlayer()==1-tp
end
-- 定义结束阶段效果的靶向函数：设置表示形式变更的操作信息
function c90440725.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置变更此卡表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 定义结束阶段效果的处理函数：将怪兽区域的此卡里侧守备表示盖放
function c90440725.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
		-- 将此卡转为里侧守备表示（陷阱怪兽转为里侧守备表示时会回到魔陷区盖放）
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
