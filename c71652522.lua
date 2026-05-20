--バトル・テレポーテーション
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽只有1只的场合，选择那1只怪兽发动。这个回合选择怪兽可以直接攻击对方玩家。这个回合的战斗阶段结束时，选择怪兽的控制权转移给对方。
function c71652522.initial_effect(c)
	-- 自己场上表侧表示存在的念动力族怪兽只有1只的场合，选择那1只怪兽发动。这个回合选择怪兽可以直接攻击对方玩家。这个回合的战斗阶段结束时，选择怪兽的控制权转移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c71652522.condition)
	e1:SetTarget(c71652522.target)
	e1:SetOperation(c71652522.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：当前处于战斗阶段结束前的阶段
function c71652522.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段结束前
	return Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 过滤条件：自己场上表侧表示的念动力族怪兽
function c71652522.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 选择效果目标：选择自己场上唯一的一只表侧表示念动力族怪兽
function c71652522.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上表侧表示的念动力族怪兽数量是否为1
	if chk==0 then return Duel.GetMatchingGroupCount(c71652522.filter,tp,LOCATION_MZONE,0,nil)==1 end
	-- 获取自己场上唯一的那只表侧表示念动力族怪兽
	local tc=Duel.GetMatchingGroup(c71652522.filter,tp,LOCATION_MZONE,0,nil):GetFirst()
	-- 将该怪兽设为效果处理的对象
	Duel.SetTargetCard(tc)
end
-- 效果处理：使目标怪兽可以直接攻击，并注册在战斗阶段结束时转移控制权的效果
function c71652522.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合选择怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合的战斗阶段结束时，选择怪兽的控制权转移给对方。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_PHASE+PHASE_BATTLE)
		e2:SetOperation(c71652522.ctop)
		e2:SetLabelObject(tc)
		-- 在全局环境注册该回合战斗阶段结束时触发的延迟效果
		Duel.RegisterEffect(e2,tp)
		tc:RegisterFlagEffect(71652522,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 战斗阶段结束时的控制权转移操作
function c71652522.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(71652522)~=0 then
		-- 将目标怪兽的控制权转移给对方
		Duel.GetControl(tc,1-tp)
	end
end
