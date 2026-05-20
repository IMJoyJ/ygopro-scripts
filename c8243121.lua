--LL－比翼の麗鳥
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「抒情歌鸲」怪兽为对象才能发动。对方场上的全部怪兽的攻击力变成和作为对象的怪兽的攻击力相同，对方场上的全部怪兽的等级·阶级变成1。
-- ②：对方怪兽向自己的「抒情歌鸲」怪兽攻击宣言时，把墓地的这张卡除外才能发动。那只自己怪兽的攻击力直到回合结束时变成和那只对方怪兽的攻击力相同。
function c8243121.initial_effect(c)
	-- ①：以自己场上1只「抒情歌鸲」怪兽为对象才能发动。对方场上的全部怪兽的攻击力变成和作为对象的怪兽的攻击力相同，对方场上的全部怪兽的等级·阶级变成1。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8243121,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,8243121)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	-- 设置发动条件为伤害步骤中伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c8243121.target)
	e1:SetOperation(c8243121.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽向自己的「抒情歌鸲」怪兽攻击宣言时，把墓地的这张卡除外才能发动。那只自己怪兽的攻击力直到回合结束时变成和那只对方怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8243121,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,8243122)
	e2:SetCondition(c8243121.atkcon)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c8243121.atktg)
	e2:SetOperation(c8243121.atkop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「抒情歌鸲」怪兽，且对方场上存在攻击力不同或等级/阶级不为1的怪兽
function c8243121.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xf7)
		-- 检查对方场上是否存在攻击力与该怪兽不同的表侧表示怪兽
		and (Duel.IsExistingMatchingCard(c8243121.atkfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
			-- 或者对方场上是否存在等级或阶级不为1的表侧表示怪兽
			or Duel.IsExistingMatchingCard(c8243121.lvfilter,tp,0,LOCATION_MZONE,1,nil))
end
-- 过滤对方场上攻击力与目标怪兽不同的表侧表示怪兽
function c8243121.atkfilter(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- 过滤对方场上等级或阶级在2以上（即不为1）的表侧表示怪兽
function c8243121.lvfilter(c)
	return c:IsFaceup() and (c:IsLevelAbove(2) or c:IsRankAbove(2))
end
-- 效果①的发动准备与对象选择
function c8243121.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c8243121.cfilter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的「抒情歌鸲」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c8243121.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「抒情歌鸲」怪兽作为对象
	Duel.SelectTarget(tp,c8243121.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果①的执行处理
function c8243121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 获取对方场上所有攻击力与对象怪兽不同的表侧表示怪兽
		local g=Duel.GetMatchingGroup(c8243121.atkfilter,tp,0,LOCATION_MZONE,nil,atk)
		local cc=g:GetFirst()
		while cc do
			-- 对方场上的全部怪兽的攻击力变成和作为对象的怪兽的攻击力相同
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			cc:RegisterEffect(e1)
			cc=g:GetNext()
		end
	end
	-- 获取对方场上所有等级或阶级不为1的表侧表示怪兽
	local lg=Duel.GetMatchingGroup(c8243121.lvfilter,tp,0,LOCATION_MZONE,nil)
	local lc=lg:GetFirst()
	while lc do
		-- 对方场上的全部怪兽的等级·阶级变成1
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		if lc:IsLevelAbove(2) then
			e2:SetCode(EFFECT_CHANGE_LEVEL)
		end
		if lc:IsRankAbove(2) then
			e2:SetCode(EFFECT_CHANGE_RANK)
		end
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		lc:RegisterEffect(e2)
		lc=lg:GetNext()
	end
end
-- 效果②的发动条件判定
function c8243121.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的对方怪兽（攻击怪兽）和自己怪兽（被攻击怪兽）
	local a,d=Duel.GetBattleMonster(1-tp)
	if not (a and d) then return false end
	-- 判定是否为对方怪兽向自己场上表侧表示的「抒情歌鸲」怪兽宣言攻击
	return Duel.GetAttacker()==a and d:IsFaceup() and d:IsSetCard(0xf7)
end
-- 效果②的发动准备与可行性检查
function c8243121.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取进行战斗的双方怪兽
	local a,d=Duel.GetBattleMonster(1-tp)
	if chk==0 then return d:GetAttack()~=a:GetAttack() end
end
-- 效果②的执行处理
function c8243121.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的双方怪兽
	local a,d=Duel.GetBattleMonster(1-tp)
	if a and d and d:IsRelateToBattle() and a:IsRelateToBattle() and d:IsFaceup() and a:IsFaceup() then
		-- 那只自己怪兽的攻击力直到回合结束时变成和那只对方怪兽的攻击力相同
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(a:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		d:RegisterEffect(e1)
	end
end
