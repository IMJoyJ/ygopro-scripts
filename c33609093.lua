--戦華史略－十万之矢
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽和自己场上1只「战华」怪兽为对象才能发动。直到回合结束时，那只对方怪兽的攻击力变成一半，那只自己怪兽的攻击力上升那个数值。
-- ②：自己场上的「战华」怪兽的属性是2种类以上，这张卡被送去墓地的场合才能发动。从手卡·卡组把「战华史略-十万之矢」以外的1张「战华」永续魔法·永续陷阱卡在自己场上表侧表示放置。
function c33609093.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以对方场上1只表侧表示怪兽和自己场上1只「战华」怪兽为对象才能发动。直到回合结束时，那只对方怪兽的攻击力变成一半，那只自己怪兽的攻击力上升那个数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33609093,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,33609093)
	e2:SetTarget(c33609093.atktg)
	e2:SetOperation(c33609093.atkop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「战华」怪兽的属性是2种类以上，这张卡被送去墓地的场合才能发动。从手卡·卡组把「战华史略-十万之矢」以外的1张「战华」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33609093,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,33609094)
	e3:SetCondition(c33609093.tfcon)
	e3:SetTarget(c33609093.tftg)
	e3:SetOperation(c33609093.tfop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上表侧表示的「战华」怪兽
function c33609093.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果处理函数，用于设置效果的对象
function c33609093.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只「战华」怪兽
		and Duel.IsExistingTarget(c33609093.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对方的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择自己的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上的1只「战华」怪兽作为效果对象
	Duel.SelectTarget(tp,c33609093.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，执行效果内容
function c33609093.atkop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsRelateToEffect(e) and hc:IsFaceup() then
		local atk=hc:GetAttack()
		-- 将对方怪兽的攻击力设置为原来的一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		hc:RegisterEffect(e1)
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			tc:RegisterEffect(e2)
		end
	end
end
-- 过滤函数，用于筛选场上表侧表示的「战华」怪兽
function c33609093.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 条件函数，判断自己场上是否存在2种以上不同属性的「战华」怪兽
function c33609093.tfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「战华」怪兽
	local g=Duel.GetMatchingGroup(c33609093.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 判断这些怪兽是否具有2种以上不同属性
	return aux.GetAttributeCount(g)>1
end
-- 过滤函数，用于筛选「战华」永续魔法或永续陷阱卡
function c33609093.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x137) and not c:IsCode(33609093)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果处理函数，用于设置效果的对象
function c33609093.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空置的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己手牌或牌组中是否存在符合条件的「战华」永续魔法或陷阱卡
		and Duel.IsExistingMatchingCard(c33609093.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理函数，执行效果内容
function c33609093.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在空置的魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择符合条件的1张「战华」永续魔法或陷阱卡
	local tc=Duel.SelectMatchingCard(tp,c33609093.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的卡放置到自己场上
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
