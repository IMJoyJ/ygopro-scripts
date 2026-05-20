--クレイジー・ファイヤー
-- 效果：
-- 支付500基本分。自己场上表侧表示存在的名字带有「烈焰加农炮」的卡破坏，场上的怪兽全部破坏。之后，在自己场上攻击表示特殊召唤1只「狂焰衍生物」（炎族·炎·3星·攻/守1000）。这个回合自己怪兽不能攻击。
function c68815401.initial_effect(c)
	-- 支付500基本分。自己场上表侧表示存在的名字带有「烈焰加农炮」的卡破坏，场上的怪兽全部破坏。之后，在自己场上攻击表示特殊召唤1只「狂焰衍生物」（炎族·炎·3星·攻/守1000）。这个回合自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c68815401.cost)
	e1:SetTarget(c68815401.target)
	e1:SetOperation(c68815401.activate)
	c:RegisterEffect(e1)
end
-- 支付500基本分，并注册本回合自己怪兽不能攻击的誓约效果。
function c68815401.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分，且本回合至今未进行过攻击。
	if chk==0 then return Duel.CheckLPCost(tp,500) and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 扣除500点基本分。
	Duel.PayLPCost(tp,500)
	-- 支付500基本分。自己场上表侧表示存在的名字带有「烈焰加农炮」的卡破坏，场上的怪兽全部破坏。之后，在自己场上攻击表示特殊召唤1只「狂焰衍生物」（炎族·炎·3星·攻/守1000）。这个回合自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该不能攻击的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤自己场上表侧表示的名字带有「烈焰加农炮」的卡。
function c68815401.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb9)
end
-- 检查发动条件：自己场上存在表侧表示的「烈焰加农炮」卡片、场上存在怪兽、且自己能特殊召唤衍生物。
function c68815401.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否存在至少1张表侧表示的「烈焰加农炮」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c68815401.filter1,tp,LOCATION_SZONE,0,1,nil)
		-- 检查双方怪兽区是否存在至少1只怪兽。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查玩家是否能在自己场上以表侧攻击表示特殊召唤1只「狂焰衍生物」（炎族·炎·3星·攻/守1000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,68815402,0,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_ATTACK) end
	-- 获取自己场上所有表侧表示的「烈焰加农炮」卡片。
	local dg1=Duel.GetMatchingGroup(c68815401.filter1,tp,LOCATION_SZONE,0,nil)
	-- 获取场上所有的怪兽。
	local dg2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	dg1:Merge(dg2)
	-- 设置操作信息：破坏自己场上的「烈焰加农炮」卡片和场上的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg1,dg1:GetCount(),0,0)
	-- 设置操作信息：涉及衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：破坏自己场上的「烈焰加农炮」卡片，若成功则破坏场上所有怪兽，若再次成功则特殊召唤「狂焰衍生物」。
function c68815401.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「烈焰加农炮」卡片。
	local dg1=Duel.GetMatchingGroup(c68815401.filter1,tp,LOCATION_SZONE,0,nil)
	-- 破坏自己场上表侧表示的「烈焰加农炮」卡片，并判断是否破坏成功。
	if Duel.Destroy(dg1,REASON_EFFECT)>0 then
		-- 获取场上所有的怪兽。
		local dg2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 破坏场上的全部怪兽，并判断是否破坏成功。
		if Duel.Destroy(dg2,REASON_EFFECT)>0
			-- 并且检查此时是否仍能特殊召唤该衍生物。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,68815402,0,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_ATTACK) then
			-- 中断当前效果处理，使后续的特殊召唤处理不与破坏同时进行。
			Duel.BreakEffect()
			-- 在卡片数据库中创建「狂焰衍生物」卡片。
			local token=Duel.CreateToken(tp,68815402)
			-- 将衍生物以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end
