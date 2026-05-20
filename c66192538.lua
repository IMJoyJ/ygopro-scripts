--ダンマリ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「@火灵天星」怪兽进行战斗的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。
-- ②：自己场上有连接6怪兽存在的场合，把场上·墓地的这张卡除外，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c66192538.initial_effect(c)
	-- ①：自己的「@火灵天星」怪兽进行战斗的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66192538,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,66192538)
	e1:SetCondition(c66192538.condition)
	e1:SetTarget(c66192538.target)
	e1:SetOperation(c66192538.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上有连接6怪兽存在的场合，把场上·墓地的这张卡除外，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66192538,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,66192539)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(c66192538.discon)
	-- 把场上·墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c66192538.distg)
	e2:SetOperation(c66192538.disop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果①的发动条件：自己的「@火灵天星」怪兽进行战斗的攻击宣言时
function c66192538.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 如果攻击怪兽不是自己，则获取被攻击的怪兽（确保判断的是自己的怪兽）
	if not at:IsControler(tp) then at=Duel.GetAttackTarget() end
	return at and at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0x135)
end
-- 效果①的发动准备与特殊召唤的操作信息注册
function c66192538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查自己场上是否有空位且手牌中的这张卡能否特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的特殊召唤与无效攻击处理
function c66192538.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于手牌且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 无效那次攻击
		Duel.NegateAttack()
	end
end
-- 过滤自己场上表侧表示的连接6怪兽
function c66192538.cfilter(c)
	return c:IsFaceup() and c:IsLink(6)
end
-- 效果②的发动条件：自己场上有连接6怪兽存在
function c66192538.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的连接6怪兽
	return Duel.IsExistingMatchingCard(c66192538.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的取对象与无效操作信息注册
function c66192538.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若在进行对象重构，检查该卡是否在对方场上且符合可无效的卡片过滤条件
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在可以被无效的卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置无效卡片效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的无效效果处理
function c66192538.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
