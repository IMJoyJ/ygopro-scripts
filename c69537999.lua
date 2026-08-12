--ブレイズ・キャノン
-- 效果：
-- ①：以对方场上1只怪兽为对象才能把这个效果发动（这个效果发动的回合，自己怪兽不能攻击）。从手卡把1只攻击力500以下的炎族怪兽送去墓地，作为对象的对方怪兽破坏。
function c69537999.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以对方场上1只怪兽为对象才能把这个效果发动（这个效果发动的回合，自己怪兽不能攻击）。从手卡把1只攻击力500以下的炎族怪兽送去墓地，作为对象的对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69537999,0))  --"对方场上存在的1只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c69537999.descost)
	e2:SetTarget(c69537999.destg)
	e2:SetOperation(c69537999.desop)
	c:RegisterEffect(e2)
end
-- 定义发动代价（Cost）函数，检查并注册本回合自己怪兽不能攻击的限制
function c69537999.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查本回合自己是否未进行过攻击
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- ①：以对方场上1只怪兽为对象才能把这个效果发动（这个效果发动的回合，自己怪兽不能攻击）。从手卡把1只攻击力500以下的炎族怪兽送去墓地，作为对象的对方怪兽破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给发动效果的玩家注册“本回合自己怪兽不能攻击”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：筛选手卡中攻击力500以下的炎族怪兽
function c69537999.disfilter(c)
	return c:IsAttackBelow(500) and c:IsRace(RACE_PYRO)
end
-- 定义效果的目标（Target）函数，进行发动条件检查并选择对象
function c69537999.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动阶段（chk==0）检查手卡是否存在至少1只攻击力500以下的炎族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69537999.disfilter,tp,LOCATION_HAND,0,1,nil)
		-- 并且对方场上是否存在至少1只可以作为对象的怪兽
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：包含破坏该对象的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：包含从手卡将1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 定义效果的处理（Operation）函数，执行送墓和破坏操作
function c69537999.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足过滤条件的炎族怪兽
	local g=Duel.SelectMatchingCard(tp,c69537999.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	local gc=g:GetFirst()
	-- 如果成功将选中的怪兽送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and gc:IsLocation(LOCATION_GRAVE) then
		-- 获取发动时选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
			-- 将作为对象的怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
