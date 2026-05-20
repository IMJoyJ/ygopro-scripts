--Evil★Twin プレゼント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「姬丝基勒」怪兽以及「璃拉」怪兽存在的场合，可以从以下效果选择1个发动。
-- ●以自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那2只怪兽的控制权交换。
-- ●以对方场上盖放的1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。
function c60759087.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「姬丝基勒」怪兽以及「璃拉」怪兽存在的场合，可以从以下效果选择1个发动。●以自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那2只怪兽的控制权交换。●以对方场上盖放的1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60759087,0))  --"交换控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,60759087+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c60759087.condition)
	e1:SetTarget(c60759087.target)
	e1:SetOperation(c60759087.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：属于指定系列且表侧表示的卡
function c60759087.cfilter(c,setcode)
	return c:IsSetCard(setcode) and c:IsFaceup()
end
-- 发动条件：自己场上存在「姬丝基勒」怪兽以及「璃拉」怪兽
function c60759087.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「姬丝基勒」怪兽
	return Duel.IsExistingMatchingCard(c60759087.cfilter,tp,LOCATION_MZONE,0,1,nil,0x152)
		-- 检查自己场上是否存在表侧表示的「璃拉」怪兽
		and Duel.IsExistingMatchingCard(c60759087.cfilter,tp,LOCATION_MZONE,0,1,nil,0x153)
end
-- 过滤条件：自己场上表侧表示、可以转移控制权且转移后不违反怪兽区域限制的「姬丝基勒」或「璃拉」怪兽
function c60759087.tgfilter1a(c)
	local tp=c:GetControler()
	return c:IsSetCard(0x152,0x153)
		and c:IsFaceup() and c:IsAbleToChangeControler()
		-- 检查该怪兽离开后，自己场上是否有可用的怪兽区域以容纳交换过来的怪兽
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤条件：对方场上表侧表示、可以转移控制权且转移后不违反怪兽区域限制的怪兽
function c60759087.tgfilter1b(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsAbleToChangeControler()
		-- 检查该怪兽离开后，对方场上是否有可用的怪兽区域以容纳交换过来的怪兽
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤条件：对方场上盖放的且能回到卡组的魔法·陷阱卡
function c60759087.tgfilter2(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 效果选择与对象选择处理（包含成为效果对象时的合法性检查）
function c60759087.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and c60759087.tgfilter1(chkc)
		and chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在满足控制权交换条件的「姬丝基勒」或「璃拉」怪兽
	local b1 = Duel.IsExistingTarget(c60759087.tgfilter1a,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在满足控制权交换条件的表侧表示怪兽
		and Duel.IsExistingTarget(c60759087.tgfilter1b,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上是否存在满足条件的盖放的魔法·陷阱卡
	local b2 = Duel.IsExistingTarget(c60759087.tgfilter2,tp,0,LOCATION_SZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动其中一个效果
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(60759087,0),0},  --"交换控制权"
		{b2,aux.Stringid(60759087,1),1})  --"回到卡组"
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择自己场上1只「姬丝基勒」或「璃拉」怪兽作为对象
		local g1=Duel.SelectTarget(tp,c60759087.tgfilter1a,tp,LOCATION_MZONE,0,1,1,nil)
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上1只表侧表示怪兽作为对象
		local g2=Duel.SelectTarget(tp,c60759087.tgfilter1b,tp,0,LOCATION_MZONE,1,1,nil)
		g1:Merge(g2)
		-- 设置操作信息：交换2只怪兽的控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
	else
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择对方场上盖放的1张魔法·陷阱卡作为对象
		local g=Duel.SelectTarget(tp,c60759087.tgfilter2,tp,0,LOCATION_SZONE,1,1,nil)
		-- 设置操作信息：将选中的1张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
end
-- 效果处理函数：根据选择的效果分支执行控制权交换或弹回卡组
function c60759087.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 获取当前连锁中作为对象的卡片组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local a=g:GetFirst()
		local b=g:GetNext()
		if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
			-- 交换这2只怪兽的控制权
			Duel.SwapControl(a,b)
		end
	else
		-- 获取作为对象的卡片
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的卡片送回持有者卡组并洗牌
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
