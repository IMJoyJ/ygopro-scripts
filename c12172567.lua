--マインド・キャスリン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡的控制权交换。
-- ②：同调召唤的这张卡被送去墓地的场合，以自己以及对方场上的表侧表示怪兽各1只为对象才能发动。那2只怪兽的控制权交换。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合，以自己以及对方场上的表侧表示怪兽各1只为对象才能发动。那2只怪兽的控制权交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end
-- 控制权交换的过滤条件函数
function s.swapfilter(c)
	local tp=c:GetControler()
	-- 满足控制权交换条件：能改变控制权、有可用怪兽区、表侧表示
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and c:IsFaceup()
end
-- 效果①的目标选择函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.swapfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToChangeControler()
		-- 满足控制权交换条件：己方有可用怪兽区
		and Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>0
		-- 满足控制权交换条件：对方场上存在满足条件的怪兽
		and Duel.IsExistingTarget(s.swapfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择控制权交换对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择对方场上满足条件的1只怪兽作为目标
	local mon=Duel.SelectTarget(tp,s.swapfilter,tp,0,LOCATION_MZONE,1,1,nil)
	mon:AddCard(e:GetHandler())
	-- 设置操作信息为控制权交换
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,mon,2,0,0)
end
-- 效果①的处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		-- 交换控制权
		Duel.SwapControl(c,tc)
	end
end
-- 效果②的发动条件函数
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 控制权交换的过滤条件函数
function s.ctfilter(c)
	local tp=c:GetControler()
	-- 满足控制权交换条件：能改变控制权、有可用怪兽区、表侧表示
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and c:IsFaceup()
end
-- 效果②的目标选择函数
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 满足控制权交换条件：己方或对方场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 满足控制权交换条件：己方场上存在满足条件的怪兽
		and Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择控制权交换对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择对方场上满足条件的1只怪兽作为目标
	local g1=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示选择控制权交换对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择己方场上满足条件的1只怪兽作为目标
	local g2=Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息为控制权交换
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果②的处理函数
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换控制权
		Duel.SwapControl(a,b)
	end
end
