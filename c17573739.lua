--神禽王アレクトール
-- 效果：
-- 对方场上相同属性的怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。1回合1次选择场上表侧表示存在的1张卡。选择的卡的效果在那个回合中无效。「神禽王 亚力克特」在场上只能有1张表侧表示存在。
function c17573739.initial_effect(c)
	c:SetUniqueOnField(1,1,17573739)
	-- 创建一个场地区域的特殊召唤规则效果，该效果满足条件时可从手卡特殊召唤此卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17573739.spcon)
	c:RegisterEffect(e1)
	-- 创建一个起动效果，每回合可以发动一次，选择场上表侧表示存在的1张卡，使该卡的效果在那个回合中无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17573739,0))  --"效果无效"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c17573739.distg)
	e2:SetOperation(c17573739.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查对方场上是否存在至少1只表侧表示且属性与指定属性相同的怪兽
function c17573739.spfilter1(c,tp)
	-- 检查对方场上是否存在至少1只表侧表示且属性与指定属性相同的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c17573739.spfilter2,tp,0,LOCATION_MZONE,1,c,c:GetAttribute())
end
-- 过滤函数：检查指定属性的怪兽是否表侧表示
function c17573739.spfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 判断特殊召唤条件是否满足：己方场上存在空位且对方场上存在至少1只表侧表示且属性相同的怪兽
function c17573739.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断己方场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方场上是否存在至少1只表侧表示且属性相同的怪兽
		and	Duel.IsExistingMatchingCard(c17573739.spfilter1,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 设置效果的目标选择函数，选择场上表侧表示存在的1张卡
function c17573739.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检查是否满足选择目标的条件：场上存在至少1张表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示存在的1张卡作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 设置效果的处理函数，使目标卡的效果无效
function c17573739.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 为目标卡添加效果无效（针对怪兽）效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为目标卡添加效果无效（针对效果）效果，该效果在结束阶段重置
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 为目标卡添加陷阱怪兽无效效果，该效果在结束阶段重置
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
