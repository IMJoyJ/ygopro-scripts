--ジャブィアント・パンダ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场上有兽战士族怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
function c36539330.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有兽战士族怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36539330+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c36539330.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：这张卡从场上送去墓地的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,36539331)
	e2:SetCondition(c36539330.tgcon)
	e2:SetTarget(c36539330.tgtg)
	e2:SetOperation(c36539330.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定怪兽是否为表侧表示且种族为兽战士族，用于检测场上是否存在符合条件的兽战士族怪兽。
function c36539330.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
-- 特殊召唤规则的条件函数：当c为nil时直接返回true表示支持规则查询；否则要求自己场上有至少2只表侧表示兽战士族怪兽且主要怪兽区有空位，才能从手卡进行规则特殊召唤。
function c36539330.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区域是否存在至少1个可用空格，确保有位置特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的场上是否存在至少2只表侧表示且种族为兽战士族的怪兽，满足①的特殊召唤条件。
		and Duel.IsExistingMatchingCard(c36539330.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
-- ②效果的发动条件：这张卡被送去墓地前所在位置是场上，即满足“从场上送去墓地”的场合。
function c36539330.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的发动目标处理：确认存在合法对象后，提示玩家选择自己场上1只表侧表示怪兽作为对象，并设置提升攻击力的操作信息。
function c36539330.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动合法性检查：判断自己场上是否存在至少1只可以成为对象的表侧表示怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动者发送选择对象的提示消息，提示内容为标准的“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 由发动者从自己场上选择1只表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息：类别为攻击力变化，对象为所选怪兽，数量为1，目标玩家为自己，变动值为500。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,500)
end
-- ②效果处理：取得对象怪兽，若对象仍与效果关联，则为其赋予攻击力上升500的效果，该效果在对象怪兽离开场上等标准重置时消失。
function c36539330.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的第一个对象卡，即被选中的己方表侧表示怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
