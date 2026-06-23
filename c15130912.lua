--ヴァリアンツの弓引－西園
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡是已特殊召唤的场合，以场上1只效果怪兽为对象才能发动。进行1次投掷硬币。表的场合，那只怪兽的效果无效。里的场合，那个攻击力变成一半。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以场上1张卡为对象才能发动。进行1次投掷硬币。表的场合，那张卡破坏。里的场合，那张卡回到持有者手卡。
function c15130912.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,15130912)
	e1:SetTarget(c15130912.sptg)
	e1:SetOperation(c15130912.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已特殊召唤的场合，以场上1只效果怪兽为对象才能发动。进行1次投掷硬币。表的场合，那只怪兽的效果无效。里的场合，那个攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,15130913)
	e2:SetCondition(c15130912.coincon1)
	e2:SetTarget(c15130912.cointg1)
	e2:SetOperation(c15130912.coinop1)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以场上1张卡为对象才能发动。进行1次投掷硬币。表的场合，那张卡破坏。里的场合，那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COIN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,15130914)
	e3:SetCondition(c15130912.coincon2)
	e3:SetTarget(c15130912.cointg2)
	e3:SetOperation(c15130912.coinop2)
	c:RegisterEffect(e3)
end
-- 设置灵摆效果的发动条件，检查是否满足特殊召唤的条件
function c15130912.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行灵摆效果的处理，将卡片特殊召唤到场上并设置不能特殊召唤非群豪怪兽的效果
function c15130912.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上指定区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 创建一个影响全场的永续效果，禁止玩家在回合结束前特殊召唤非群豪怪兽（除额外卡组外）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c15130912.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的永续效果注册到游戏环境中
	Duel.RegisterEffect(e1,tp)
end
-- 定义不能特殊召唤的条件，即不是群豪卡组且不在额外卡组的怪兽不能特殊召唤
function c15130912.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 判断该卡是否为特殊召唤状态
function c15130912.coincon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 定义用于选择目标的过滤器，选择正面表示的效果怪兽
function c15130912.coinfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 设置投掷硬币效果的目标选择函数，选择一个正面表示的效果怪兽
function c15130912.cointg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15130912.coinfilter1(chkc) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c15130912.coinfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择一个正面表示的效果怪兽作为目标
	Duel.SelectTarget(tp,c15130912.coinfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要进行一次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 执行投掷硬币效果的处理，根据硬币结果对目标怪兽进行效果处理
function c15130912.coinop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	-- 进行一次硬币投掷
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		if tc:IsCanBeDisabledByEffect(e) then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 创建一个使目标怪兽效果无效的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
	else
		-- 创建一个使目标怪兽攻击力减半的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断该卡是否在移动后处于不同区域或控制权发生变化
function c15130912.coincon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 设置移动后触发效果的目标选择函数，选择场上的任意一张卡
function c15130912.cointg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否有符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择一张场上的卡作为目标
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要进行一次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 执行移动后触发效果的处理，根据硬币结果对目标卡进行效果处理
function c15130912.coinop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 进行一次硬币投掷
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	else
		-- 将目标卡送回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
