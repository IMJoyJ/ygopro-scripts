--グレイドル・コンバット
-- 效果：
-- ①：只以自己场上的「灰篮」怪兽1只为对象的怪兽的效果·魔法·陷阱卡发动时，可以从以下效果选择1个发动。
-- ●那个效果变成「作为对象的1只怪兽破坏」。
-- ●那个发动无效并破坏。
function c84442536.initial_effect(c)
	-- ①：只以自己场上的「灰篮」怪兽1只为对象的怪兽的效果·魔法·陷阱卡发动时，可以从以下效果选择1个发动。●那个效果变成「作为对象的1只怪兽破坏」。●那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c84442536.condition)
	e1:SetTarget(c84442536.target)
	e1:SetOperation(c84442536.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「灰篮」怪兽
function c84442536.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0xd1)
end
-- 检查发动的效果是否是取对象的怪兽效果或魔法·陷阱卡的发动
function c84442536.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return c84442536.cfilter(tc,tp)
end
-- 效果发动的目标选择与合法性检测，根据当前连锁是否可被无效以及对象怪兽是否在场，让玩家选择要发动的效果分支并设置对应的操作信息
function c84442536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 检查当前连锁是否可以被无效，或者作为对象的怪兽是否仍在怪兽区
	if chk==0 then return tc and (Duel.IsChainNegatable(ev) or tc:IsLocation(LOCATION_MZONE)) end
	local sel=0
	-- 如果当前连锁可以被无效，且作为对象的怪兽仍在怪兽区，则两个效果分支都可以选择
	if Duel.IsChainNegatable(ev) and tc:IsLocation(LOCATION_MZONE) then
		-- 提示玩家选择要发动的效果
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 让玩家在“变更效果为破坏对象”和“无效并破坏”两个选项中进行选择
		sel=Duel.SelectOption(tp,aux.Stringid(84442536,0),aux.Stringid(84442536,1))  --"那个效果变成「作为对象的1只怪兽破坏」/那个发动无效并破坏"
	elseif tc:IsLocation(LOCATION_MZONE) then
		-- 提示玩家选择要发动的效果
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 只能选择“变更效果为破坏对象”选项
		sel=Duel.SelectOption(tp,aux.Stringid(84442536,0))  --"那个效果变成「作为对象的1只怪兽破坏」"
	else
		-- 提示玩家选择要发动的效果
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 只能选择“无效并破坏”选项，并将选择索引设为1
		sel=Duel.SelectOption(tp,aux.Stringid(84442536,1))+1  --"那个发动无效并破坏"
	end
	e:SetLabel(sel)
	if sel==1 then
		-- 设置操作信息，表示该连锁包含使发动无效的效果
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			-- 设置操作信息，表示该连锁包含破坏卡片的效果
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
	end
end
-- 效果处理函数，根据玩家的选择，执行“变更效果”或“无效并破坏”的操作
function c84442536.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 将当前连锁的效果处理函数替换为指定的破坏对象怪兽的函数
		Duel.ChangeChainOperation(ev,c84442536.repop)
	else
		-- 尝试无效该连锁的发动，并检查发动效果的卡是否仍存在于原本的位置
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 因效果破坏发动被无效的卡
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
-- 替换后的效果处理函数，用于执行“作为对象的1只怪兽破坏”的效果
function c84442536.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏作为对象的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
