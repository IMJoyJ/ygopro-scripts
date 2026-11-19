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
-- 定义场上怪兽过滤函数，检查怪兽是否为表侧表示且属于指定字段setcode。
function c60759087.cfilter(c,setcode)
	return c:IsSetCard(setcode) and c:IsFaceup()
end
-- 发动条件检查函数：确认自己怪兽区同时存在表侧表示的「姬丝基勒」怪兽和「璃拉」怪兽。
function c60759087.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只表侧表示的「姬丝基勒」(0x152)怪兽。
	return Duel.IsExistingMatchingCard(c60759087.cfilter,tp,LOCATION_MZONE,0,1,nil,0x152)
		-- 检查自己怪兽区是否存在至少1只表侧表示的「璃拉」(0x153)怪兽。
		and Duel.IsExistingMatchingCard(c60759087.cfilter,tp,LOCATION_MZONE,0,1,nil,0x153)
end
-- 定义交换控制权己方对象过滤函数：检查怪兽是否表侧表示、属于「姬丝基勒」或「璃拉」、可以改变控制权，且离场后其控制者怪兽区有空位接收对方怪兽。
function c60759087.tgfilter1a(c)
	local tp=c:GetControler()
	return c:IsSetCard(0x152,0x153)
		and c:IsFaceup() and c:IsAbleToChangeControler()
		-- 检查该怪兽离开后其当前控制者场上是否仍有至少1个可用于改变控制权的怪兽区空位。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 定义交换控制权对方对象过滤函数：检查怪兽是否表侧表示、可以改变控制权，且离场后其控制者怪兽区有空位接收己方怪兽。
function c60759087.tgfilter1b(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsAbleToChangeControler()
		-- 检查对方怪兽离开后其当前控制者场上是否仍有至少1个可用于改变控制权的怪兽区空位。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 定义返回卡组对象过滤函数：检查卡片是否为里侧表示且可以被送回卡组。
function c60759087.tgfilter2(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 目标检查与选项分支处理函数：检查在存在多对象或选项1时对象仍合法，随后在效果1和效果2中判定各自发动条件。
function c60759087.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and c60759087.tgfilter2(chkc)
		and chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) end
	-- 检查自己怪兽区是否存在至少1只满足交换控制权条件的「姬丝基勒」或「璃拉」怪兽作为对象。
	local b1 = Duel.IsExistingTarget(c60759087.tgfilter1a,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方怪兽区是否存在至少1只满足交换控制权条件的表侧表示怪兽作为对象。
		and Duel.IsExistingTarget(c60759087.tgfilter1b,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方魔法与陷阱区是否存在至少1张盖放且可回到卡组的卡片作为对象。
	local b2 = Duel.IsExistingTarget(c60759087.tgfilter2,tp,0,LOCATION_SZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让发动玩家从满足发动条件的效果选项（交换控制权或回到卡组）中选择其一。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(60759087,0),0},  --"交换控制权"
		{b2,aux.Stringid(60759087,1),1})  --"回到卡组"
	e:SetLabel(op)
	if op==0 then
		-- 向玩家发送选择要改变控制权的己方怪兽的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家从自己怪兽区选择1只满足条件的「姬丝基勒」或「璃拉」怪兽作为对象。
		local g1=Duel.SelectTarget(tp,c60759087.tgfilter1a,tp,LOCATION_MZONE,0,1,1,nil)
		-- 向玩家发送选择要改变控制权的对方怪兽的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家从对方怪兽区选择1只满足条件的表侧表示怪兽作为对象。
		local g2=Duel.SelectTarget(tp,c60759087.tgfilter1b,tp,0,LOCATION_MZONE,1,1,nil)
		g1:Merge(g2)
		-- 向引擎登记本次连锁确定交换所选2只怪兽控制权的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
	else
		-- 向玩家发送选择要返回卡组的对方盖放魔陷的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从对方魔法与陷阱区选择1张里侧盖放的卡作为对象。
		local g=Duel.SelectTarget(tp,c60759087.tgfilter2,tp,0,LOCATION_SZONE,1,1,nil)
		-- 向引擎登记本次连锁确定将对象卡送回卡组的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
end
-- 效果处理函数：根据发动时记录的选项分支，交换2只对象怪兽的控制权或将对方盖放的对象魔陷送回持有者卡组并洗切。
function c60759087.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 获取当前连锁指定的所有对象卡片组。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local a=g:GetFirst()
		local b=g:GetNext()
		if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
			-- 交换对象怪兽a与对象怪兽b的控制权。
			Duel.SwapControl(a,b)
		end
	else
		-- 获取当前连锁指定的单个对象卡片。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 以效果原因将对象卡送回持有者的卡组并标记洗切卡组。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
