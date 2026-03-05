--魔界劇団－コミック・リリーフ
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以对方场上1只怪兽和自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。那2只怪兽的控制权交换。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：自己准备阶段发动。这张卡的控制权移给对方。
-- ③：1回合1次，这张卡的控制权转移的场合发动。这张卡的原本持有者可以选自身的魔法与陷阱区域盖放的1张「魔界台本」魔法卡破坏。
function c15308295.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：以对方场上1只怪兽和自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。那2只怪兽的控制权交换。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15308295,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,15308295)
	e1:SetTarget(c15308295.cttg)
	e1:SetOperation(c15308295.ctop)
	c:RegisterEffect(e1)
	-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：自己准备阶段发动。这张卡的控制权移给对方。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15308295,1))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c15308295.ctcon)
	e4:SetTarget(c15308295.cttg2)
	e4:SetOperation(c15308295.ctop2)
	c:RegisterEffect(e4)
	-- ③：1回合1次，这张卡的控制权转移的场合发动。这张卡的原本持有者可以选自身的魔法与陷阱区域盖放的1张「魔界台本」魔法卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(15308295,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_CONTROL_CHANGED)
	e5:SetCountLimit(1)
	e5:SetTarget(c15308295.destg)
	e5:SetOperation(c15308295.desop)
	c:RegisterEffect(e5)
end
-- 过滤满足条件的「魔界剧团」灵摆怪兽，包括正面表示、属于「魔界剧团」、灵摆怪兽类型、可以改变控制权且目标玩家场上存在可用怪兽区
function c15308295.ctfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToChangeControler()
		-- 检查目标玩家场上是否存在可用怪兽区，确保可以进行控制权转移
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤满足条件的怪兽，包括可以改变控制权且目标玩家场上存在可用怪兽区
function c15308295.ctfilter2(c)
	local tp=c:GetControler()
	-- 检查目标玩家场上是否存在可用怪兽区，确保可以进行控制权转移
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 判断是否满足选择目标的条件，即对方场上存在可选怪兽和己方场上存在可选「魔界剧团」灵摆怪兽
function c15308295.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c15308295.ctfilter2,tp,0,LOCATION_MZONE,1,nil)
		-- 判断己方场上是否存在满足条件的「魔界剧团」灵摆怪兽
		and Duel.IsExistingTarget(c15308295.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的1只满足条件的怪兽作为目标
	local g1=Duel.SelectTarget(tp,c15308295.ctfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择己方场上的1只满足条件的「魔界剧团」灵摆怪兽作为目标
	local g2=Duel.SelectTarget(tp,c15308295.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，表示将交换2只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
	-- 设置操作信息，表示将破坏此卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 处理控制权交换和破坏效果，先获取连锁中的目标卡片组，再交换控制权，然后破坏此卡
function c15308295.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	-- 判断交换控制权的两个目标是否仍然有效，若有效则执行控制权交换
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) and Duel.SwapControl(a,b) then
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 以效果原因破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断是否为当前回合玩家触发准备阶段效果
function c15308295.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置操作信息，表示将改变此卡的控制权
function c15308295.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置操作信息，表示将改变此卡的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 处理准备阶段效果，将此卡的控制权转移给对方
function c15308295.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡的控制权转移给对方
		Duel.GetControl(c,1-tp)
	end
end
-- 过滤满足条件的「魔界台本」魔法卡，包括背面表示、魔法卡类型、属于「魔界台本」
function c15308295.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec)
end
-- 设置操作信息，表示将破坏对方魔法与陷阱区域的魔法卡
function c15308295.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将破坏对方魔法与陷阱区域的魔法卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,e:GetHandler():GetOwner(),LOCATION_SZONE)
end
-- 处理控制权转移后的效果，询问原本持有者是否选择破坏一张「魔界台本」魔法卡
function c15308295.desop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	-- 获取原本持有者魔法与陷阱区域的「魔界台本」魔法卡组
	local g=Duel.GetMatchingGroup(c15308295.desfilter,p,LOCATION_SZONE,0,nil)
	-- 判断原本持有者魔法与陷阱区域是否存在「魔界台本」魔法卡，并询问是否选择破坏
	if g:GetCount()>0 and Duel.SelectYesNo(p,aux.Stringid(15308295,3)) then  --"是否选「魔界台本」魔法卡破坏？"
		-- 提示玩家选择要破坏的魔法卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(p,1,1,nil)
		-- 以效果原因破坏选定的魔法卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
