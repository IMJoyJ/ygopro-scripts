--強制切断
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以连接怪兽以外的自己场上1只表侧表示怪兽和对方场上1只连接怪兽为对象才能发动。那2只怪兽的控制权交换。
function c75153328.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以连接怪兽以外的自己场上1只表侧表示怪兽和对方场上1只连接怪兽为对象才能发动。那2只怪兽的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,75153328+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c75153328.target)
	e1:SetOperation(c75153328.activate)
	c:RegisterEffect(e1)
end
-- 过滤连接怪兽以外的自己场上表侧表示、可以改变控制权且离场后能空出怪兽区域的怪兽
function c75153328.filter1(c)
	local tp=c:GetControler()
	return c:IsFaceup() and not c:IsType(TYPE_LINK)
		-- 判定怪兽是否可以改变控制权，以及该怪兽离开当前场上后其控制者是否有可用的怪兽区域
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤对方场上表侧表示、可以改变控制权且离场后能空出怪兽区域的连接怪兽
function c75153328.filter2(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsType(TYPE_LINK)
		-- 判定怪兽是否可以改变控制权，以及该怪兽离开当前场上后其控制者是否有可用的怪兽区域
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果发动时的对象选择与合法性检测，检查双方场上是否存在满足条件的对应怪兽
function c75153328.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只表侧表示且可以改变控制权的非连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c75153328.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在1只表侧表示且可以改变控制权的连接怪兽
		and Duel.IsExistingTarget(c75153328.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择要改变控制权的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只满足条件的非连接怪兽作为效果的对象
	local g1=Duel.SelectTarget(tp,c75153328.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 给玩家发送选择要改变控制权的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的连接怪兽作为效果的对象
	local g2=Duel.SelectTarget(tp,c75153328.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置当前连锁的操作信息为改变2张卡片的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理时，获取作为对象的2只怪兽，若它们都仍对该效果有效，则交换它们的控制权
function c75153328.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这两只怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
