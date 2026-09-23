--装甲魔導士パズー
local s,id,o=GetID()
-- 初始化卡片效果：注册手牌·墓地当作装备卡装备，以及在场上有骰子效果卡时无效对方效果的处理
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。手卡·墓地的这张卡当作装备魔法卡使用给那只怪兽装备。自己基本分是4000以下的场合，装备怪兽的攻击力·守备力上升2100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：有骰子投掷效果的卡在自己场上存在，对方发动的效果处理时，可以把用自身的效果装备中的这张卡除外。那个场合，那个对方的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示怪兽
function s.eqfilter(c)
	return c:IsFaceup()
end
-- 装备效果取对象及操作信息设置
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 检查魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在表侧表示怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要装备的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	local c=e:GetHandler()
	-- 选择自己场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 若在墓地发动，设置离开墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 效果处理：将自身当作装备卡给对象怪兽装备，并赋予攻守上升效果及装备标记
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认自身与连锁有联系且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 检查魔陷区是否有空位及对象怪兽是否依然合法
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToChain() or not tc:IsLocation(LOCATION_MZONE) then
			-- 若不满足装备条件，依据规则将自身送去墓地
			Duel.SendtoGrave(c,REASON_RULE)
			return
		end
		-- 执行装备操作，若装备失败则终止处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 手卡·墓地的这张卡当作装备魔法卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 自己基本分是4000以下的场合，装备怪兽的攻击力·守备力上升2100。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(2100)
		e2:SetCondition(s.atkcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 装备限制：只能装备给指定的目标怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击力·守备力上升效果的适用条件判定
function s.atkcon(e)
	-- 判断自身LP是否在4000以下
	return Duel.GetLP(e:GetHandlerPlayer())<=4000
end
-- 过滤场上带有骰子效果的表侧表示卡片
function s.disfilter(c)
	-- 检查卡片是否表侧表示且持有投掷骰子属性的效果
	return c:IsFaceup() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_DICE))
end
-- 无效效果的发动条件判定
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是对方发动的效果且该效果可以被无效
	return rp==1-tp and Duel.IsChainDisablable(ev)
		-- 确认自己场上存在持有掷骰子效果的卡
		and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and e:GetHandler():IsAbleToRemove()
		and e:GetHandler():GetFlagEffect(id)>0
end
-- 效果处理：可将自身除外使对方发动的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问是否将自身除外使效果无效
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2))
		-- 使对方的发动效果无效
		and Duel.NegateEffect(ev) then
		-- 分隔前后效果处理时点
		Duel.BreakEffect()
		-- 将自身表侧表示除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
