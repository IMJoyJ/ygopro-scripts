--マインド・キャスリン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡的控制权交换。
-- ②：同调召唤的这张卡被送去墓地的场合，以自己以及对方场上的表侧表示怪兽各1只为对象才能发动。那2只怪兽的控制权交换。
local s,id,o=GetID()
-- 初始化函数：为这张卡添加同调召唤手续（调整＋调整以外的怪兽1只以上）、苏生限制，并注册①和②两个效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意调整）＋1只以上调整以外的怪兽，作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文的①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"控制权交换"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 对应效果原文的②：同调召唤的这张卡被送去墓地的场合，以自己以及对方场上的表侧表示怪兽各1只为对象才能发动。那2只怪兽的控制权交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"控制权交换"
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
-- 定义效果①②通用的对象筛选函数：用于选择可改变控制权且其控制者拥有足够空余怪兽区的表侧表示怪兽。
function s.swapfilter(c)
	local tp=c:GetControler()
	-- 筛选条件：怪兽是表侧表示、可以改变控制权，并且其当前控制者有至少1个空余怪兽区可容纳交换过来的怪兽。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and c:IsFaceup()
end
-- 效果①的发动条件和取对象处理：确认这张卡自身可改变控制权、己方有怪兽区空位，且对方场上有满足条件的表侧怪兽；选择对象时把对方怪兽和这张卡一起作为操作信息对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.swapfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToChangeControler()
		-- 确认这张卡交换后需要进入对方场地的怪兽区，因此检查其控制者（己方）当前是否有空余怪兽区。
		and Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>0
		-- 确认对方场上有至少1只满足交换条件的表侧表示怪兽可以作为对象。
		and Duel.IsExistingTarget(s.swapfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只满足条件的表侧表示怪兽作为效果对象，并自动关联到当前连锁。
	local mon=Duel.SelectTarget(tp,s.swapfilter,tp,0,LOCATION_MZONE,1,1,nil)
	mon:AddCard(e:GetHandler())
	-- 设置操作信息：本次连锁将变更2张卡（所选对方怪兽与自身）的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,mon,2,0,0)
end
-- 效果①处理时：取出对象怪兽与自身，确认双方都仍与效果关联后，交换这两张卡的控制权。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动①效果时选择的对象，即对方场上的那只表侧怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		-- 将这张卡和对象怪兽交换控制权。
		Duel.SwapControl(c,tc)
	end
end
-- 效果②的发动条件：这张卡被送去墓地的场合，且必须是同调召唤后被送去墓地（之前位置为怪兽区）。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义效果②对象筛选函数：用于选择可改变控制权且其控制者拥有足够空余怪兽区的表侧表示怪兽。
function s.ctfilter(c)
	local tp=c:GetControler()
	-- 筛选条件：怪兽是表侧表示、可以改变控制权，并且其当前控制者有至少1个空余怪兽区可容纳交换过来的怪兽。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and c:IsFaceup()
end
-- 效果②的发动条件和取对象处理：确认双方场上各存在至少1只满足条件的表侧怪兽，然后分别选择对象并合并。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 确认对方场上有至少1只满足条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 确认自己场上有至少1只满足条件的表侧表示怪兽。
		and Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要改变控制权的怪兽”的选择提示（选择对方怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只满足条件的表侧怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向玩家显示“请选择要改变控制权的怪兽”的选择提示（选择己方怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从自己场上选择1只满足条件的表侧怪兽作为对象。
	local g2=Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本次连锁将变更2张卡（己方怪兽和对方怪兽）的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果②处理时：从连锁信息中取得两个对象，确认都仍与效果关联后交换它们的控制权。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标卡组，即发动②时选择的己方和对方各1只怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 将两只怪兽的控制权交换。
		Duel.SwapControl(a,b)
	end
end
