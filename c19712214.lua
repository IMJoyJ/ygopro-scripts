--海晶乙女渦輪
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从自己的额外卡组·墓地选1只「海晶少女 水晶心」特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只连接2以上的「海晶少女」连接怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作出最多有自身的连接标记数量的攻击，那只怪兽的战斗发生的对对方的战斗伤害变成0。
function c19712214.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从自己的额外卡组·墓地选1只「海晶少女 水晶心」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,19712214+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19712214.target)
	e1:SetOperation(c19712214.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只连接2以上的「海晶少女」连接怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作出最多有自身的连接标记数量的攻击，那只怪兽的战斗发生的对对方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果只能在战斗阶段中发动（从战斗阶段开始到结束之间，且满足玩家可进入战斗阶段的条件）。
	e2:SetCondition(aux.bpcon)
	-- 设置②效果发动时需将墓地中的这张卡除外作为代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19712214.attg)
	e2:SetOperation(c19712214.atop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤对象的筛选条件：卡名为「海晶少女 水晶心」（67712104），可以被特殊召唤；若在墓地则需我方主要怪兽区有空位，若在额外卡组则需我方有可用的额外怪兽区/连接召唤可用区域。
function c19712214.spfilter(c,e,tp)
	return c:IsCode(67712104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且当候选卡位于墓地时，要求我方场上有可用的主要怪兽区空格。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 或者当候选卡位于额外卡组时，要求我方有可用的额外怪兽区（或可由额外卡组特殊召唤的空格）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的发动目标判定与操作登记：确认额外卡组·墓地存在符合条件的「海晶少女 水晶心」，并设置本次处理为从额外卡组·墓地特殊召唤1只的类别信息。
function c19712214.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认从自己的额外卡组·墓地中能找到至少1只满足spfilter的「海晶少女 水晶心」。
	if chk==0 then return Duel.IsExistingMatchingCard(c19712214.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果将进行特殊召唤，数量为1，涉及位置为持有者的额外卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 处理①效果：若攻击无效成功，则从符合条件的候选卡中选1只「海晶少女 水晶心」特殊召唤到自己场上。
function c19712214.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足特殊召唤条件的「海晶少女 水晶心」（经王家长眠之谷过滤后）作为候选集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19712214.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	-- 如果此次攻击被成功无效，且候选集合非空，则继续执行特殊召唤处理。
	if Duel.NegateAttack() and #g>0 then
		-- 向操作玩家显示选择要特殊召唤的卡片的提示信息（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「海晶少女 水晶心」以表侧表示特殊召唤到操作玩家场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果选择对象的条件：表侧表示、属于「海晶少女」系列（0x12b）、连接怪兽且连接标记数量在2以上。
function c19712214.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsLinkAbove(2)
end
-- ②效果的目标选择处理：检查并选择我方场上1只符合条件的「海晶少女」连接怪兽作为效果对象。
function c19712214.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19712214.tgfilter(chkc) end
	-- 发动合法性检查：确认我方场上存在至少1只满足tgfilter且可作为效果对象的「海晶少女」连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(c19712214.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择效果对象的提示信息（HINTMSG_TARGET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作玩家从我方场上选择1只满足条件的「海晶少女」连接怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c19712214.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理②效果：为对象怪兽赋予本回合内增加攻击次数（使其总攻击次数达到其连接标记数量）的效果，并使其对对方造成的战斗伤害变为0。
function c19712214.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作出最多有自身的连接标记数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(tc:GetLink()-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的战斗发生的对对方的战斗伤害变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetCondition(c19712214.damcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetCondition(c19712214.damcon2)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
	end
end
-- 判断对象怪兽的控制者是否为效果持有者玩家；若是，则EFFECT_NO_BATTLE_DAMAGE生效，即对方受到的战斗伤害变为0。
function c19712214.damcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 判断对象怪兽的控制者是否不是效果持有者玩家；若被对方控制，则使效果持有者玩家不会受到该怪兽战斗产生的战斗伤害（防止控制权转移后伤害反转）。
function c19712214.damcon2(e)
	return 1-e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
