--カウンター・ゲート
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。那次攻击无效，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽表侧攻击表示通常召唤。
function c94561645.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。那次攻击无效，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽表侧攻击表示通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c94561645.condition)
	e1:SetTarget(c94561645.target)
	e1:SetOperation(c94561645.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件
function c94561645.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 定义效果的发动目标与操作信息
function c94561645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家是否具有抽1张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 向系统注册该效果包含抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果的具体处理逻辑
function c94561645.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该攻击，若成功则让玩家因效果抽1张卡
	if Duel.NegateAttack() and Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 获取刚刚因效果抽到的卡片
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsType(TYPE_MONSTER) and tc:IsSummonable(true,nil)
			-- 若抽到的卡是怪兽且可以通常召唤，则提示玩家选择是否进行通常召唤
			and Duel.SelectYesNo(tp,aux.Stringid(94561645,0)) then  --"是否表侧攻击表示通常召唤？"
			-- 中断当前效果处理，使后续的召唤处理不与抽卡同时进行（防止错时点）
			Duel.BreakEffect()
			-- 让玩家将该怪兽表侧攻击表示通常召唤（无视每回合通常召唤次数限制）
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
