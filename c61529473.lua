--真竜の黙示録
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，①②的效果在同一连锁上不能发动。
-- ①：以自己场上1张其他的「真龙」卡为对象才能发动。那张卡破坏，对方场上的全部表侧表示怪兽的攻击力·守备力变成一半。
-- ②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c61529473.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：以自己场上1张其他的「真龙」卡为对象才能发动。那张卡破坏，对方场上的全部表侧表示怪兽的攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61529473,0))  --"攻击力·守备力减半"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,61529473)
	-- 设置效果在伤害步骤中伤害计算前可以发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c61529473.cost)
	e2:SetTarget(c61529473.atktg)
	e2:SetOperation(c61529473.atkop)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61529473,1))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,61529474)
	e3:SetCondition(c61529473.sumcon)
	e3:SetCost(c61529473.cost)
	e3:SetTarget(c61529473.sumtg)
	e3:SetOperation(c61529473.sumop)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61529473,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,61529475)
	e4:SetCondition(c61529473.descon)
	e4:SetTarget(c61529473.destg)
	e4:SetOperation(c61529473.desop)
	c:RegisterEffect(e4)
end
-- 定义①②效果在同一连锁上不能发动的Cost函数
function c61529473.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前连锁中是否已发动过该卡的效果
	if chk==0 then return Duel.GetFlagEffect(tp,61529473)==0 end
	-- 在当前连锁中注册已发动效果的标识，限制同一连锁内不能再次发动
	Duel.RegisterFlagEffect(tp,61529473,RESET_CHAIN,0,1)
end
-- 过滤自己场上表侧表示的「真龙」卡
function c61529473.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf9)
end
-- 定义效果①的靶向与发动合法性检测
function c61529473.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c61529473.tgfilter(chkc) and chkc~=c end
	-- 检查自己场上是否存在除自身以外的表侧表示「真龙」卡
	if chk==0 then return Duel.IsExistingTarget(c61529473.tgfilter,tp,LOCATION_ONFIELD,0,1,c)
		-- 检查对方场上是否存在表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张其他的表侧表示「真龙」卡作为效果对象
	local g=Duel.SelectTarget(tp,c61529473.tgfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果①的处理函数
function c61529473.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选中的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于场上，则将其破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc2=g:GetFirst()
		while tc2 do
			-- 对方场上的全部表侧表示怪兽的攻击力·守备力变成一半。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(math.ceil(tc2:GetAttack()/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(math.ceil(tc2:GetDefense()/2))
			tc2:RegisterEffect(e2)
			tc2=g:GetNext()
		end
	end
end
-- 定义效果②的发动条件判定函数
function c61529473.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤手卡中可以进行上级召唤的「真龙」怪兽
function c61529473.sumfilter(c)
	return c:IsSetCard(0xf9) and c:IsSummonable(true,nil,1)
end
-- 定义效果②的靶向与发动合法性检测
function c61529473.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以进行上级召唤的「真龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61529473.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁的操作信息为进行召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 定义效果②的处理函数
function c61529473.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1只满足上级召唤条件的「真龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c61529473.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合的通常召唤次数限制，对选中的怪兽进行上级召唤
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 定义效果③的发动条件判定函数（检查是否从魔陷区送去墓地）
function c61529473.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 定义效果③的靶向与发动合法性检测
function c61529473.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果③的处理函数
function c61529473.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果③选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏选中的对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
