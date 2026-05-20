--鉄巨人アイアンハンマー
-- 效果：
-- 自己场上有「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」存在的场合，这张卡可以从手卡特殊召唤。这张卡只要在场上表侧表示存在，不能把表示形式变更。此外，1回合1次，选择自己场上1只怪兽才能发动。这个回合，选择的怪兽可以直接攻击对方玩家。
function c79185500.initial_effect(c)
	-- 自己场上有「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79185500.spcon)
	c:RegisterEffect(e1)
	-- 这张卡只要在场上表侧表示存在，不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，选择自己场上1只怪兽才能发动。这个回合，选择的怪兽可以直接攻击对方玩家。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79185500,0))  --"直接攻击"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c79185500.target)
	e3:SetOperation(c79185500.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否表侧表示且卡号为指定卡号
function c79185500.spfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 特殊召唤规则的条件函数：检查怪兽区域是否有空位，且场上是否存在指定的3张卡
function c79185500.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,0)~=0
		-- 检查自己场上是否存在表侧表示的「异次元超能人·星斗罗宾」
		and Duel.IsExistingMatchingCard(c79185500.spfilter,tp,LOCATION_ONFIELD,0,1,nil,80208158)
		-- 检查自己场上是否存在表侧表示的「野兽战士 豹人」
		and Duel.IsExistingMatchingCard(c79185500.spfilter,tp,LOCATION_ONFIELD,0,1,nil,16796157)
		-- 检查自己场上是否存在表侧表示的「凤王兽 铠楼罗」
		and Duel.IsExistingMatchingCard(c79185500.spfilter,tp,LOCATION_ONFIELD,0,1,nil,43791861)
end
-- 效果发动目标选择：检查并选择自己场上1只表侧表示的怪兽作为效果对象
function c79185500.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动检查阶段，确认自己场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：使选择的怪兽在回合结束前可以直接攻击对方玩家
function c79185500.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
