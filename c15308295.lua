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
	-- 为这张卡启用灵摆怪兽属性：使其既能作为灵摆卡在灵摆区发动，也能进行灵摆召唤，并支持相关灵摆处理。
	aux.EnablePendulumAttribute(c)
	-- “这个卡名的灵摆效果1回合只能使用1次。①：以对方场上1只怪兽和自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。那2只怪兽的控制权交换。那之后，这张卡破坏。”
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
	-- “①：这张卡的战斗发生的对自己的战斗伤害变成0。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- “②：自己准备阶段发动。这张卡的控制权移给对方。”
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
	-- “③：1回合1次，这张卡的控制权转移的场合发动。这张卡的原本持有者可以选自身的魔法与陷阱区域盖放的1张「魔界台本」魔法卡破坏。”
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
-- 该筛选器用于选择己方场上的「魔界剧团」灵摆怪兽：必须是表侧表示、属于「魔界剧团」（0x10ec）、是灵摆怪兽、能够变更控制权，并且其控制者在它离开后仍有可用怪兽区以承接对方怪兽。
function c15308295.ctfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToChangeControler()
		-- 检查该候选怪兽的控制者在候选怪兽离场后仍有可用的主要怪兽区，保证交换控制权后对方怪兽能落到自己场上（受格子限制效果影响）。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 该筛选器用于选择对方场上的可交换怪兽：怪兽本身能变更控制权，且其当前控制者在它离开后仍有可用怪兽区以承接己方怪兽。
function c15308295.ctfilter2(c)
	local tp=c:GetControler()
	-- 检查该怪兽可以变更控制权，并且它的控制者在它离场后仍有空闲怪兽区用来放置交换过来的怪兽。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 灵摆效果的目标设定函数：在效果发动检查阶段，确保对方场上存在1只可变更控制权的怪兽，且自己场上存在1只符合条件的「魔界剧团」灵摆怪兽；否则不能发动。chkc非空时直接返回false，表示不进行单卡合法性再判，实际对象通过后续SelectTarget重新选择。
function c15308295.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在chk==0（发动合法性检查）时，先检查对方场上是否存在至少1只满足ctfilter2条件的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c15308295.ctfilter2,tp,0,LOCATION_MZONE,1,nil)
		-- 同时检查自己场上是否存在至少1只满足ctfilter条件的「魔界剧团」灵摆怪兽可供选择；两项都满足才可发动。
		and Duel.IsExistingTarget(c15308295.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送选择提示，提示消息为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上的怪兽中选择1只满足ctfilter2条件的怪兽作为对象，SelectTarget会将其登记到当前连锁的对象中。
	local g1=Duel.SelectTarget(tp,c15308295.ctfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向操作玩家发送选择提示，提示消息为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从自己场上的怪兽中选择1只满足ctfilter条件的「魔界剧团」灵摆怪兽作为对象。
	local g2=Duel.SelectTarget(tp,c15308295.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁的操作信息：将已选择的两只怪兽标记为改变控制权的对象，数量为2，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
	-- 设置连锁的操作信息：把这张灵摆卡标记为将被效果破坏的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的解决处理：取出效果对象；若两只对象怪兽仍与效果相关，就交换它们的控制权；交换成功后才中断时点，并破坏这张卡。
function c15308295.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得发动效果时登记的对象卡片组（这里应为两只被选中的怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	-- 确认两只对象怪兽仍与本次效果相关（没有离场或效果被无效），并且控制权交换操作成功；若成立才继续破坏这张卡。
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) and Duel.SwapControl(a,b) then
		-- Duel.BreakEffect中断当前效果处理，使后续的破坏相对于之前的控制权交换不作为同一时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 以效果原因破坏效果持有者这张卡，对应“那之后，这张卡破坏”。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 怪兽效果②的发动条件：只有当效果发动方（即这张卡当前控制者）是回合玩家时才满足条件，保证在“自己准备阶段”触发。
function c15308295.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前效果发动方是否就是回合玩家；是则条件成立，否则不发动。
	return tp==Duel.GetTurnPlayer()
end
-- 必发诱发效果的目标函数：发动时不需要选取对象，合法性检查直接返回true；同时设置操作信息为将这张卡的控制权转移给对方。
function c15308295.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置操作信息：把这张卡本身登记为改变控制权效果的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 怪兽效果②的解决处理：若这张卡仍与效果相关，则将其控制权转移给对方玩家。
function c15308295.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 令这张卡的控制权变为对方玩家（1-tp）。
		Duel.GetControl(c,1-tp)
	end
end
-- 筛选可被破坏的卡：必须是盖放的魔法卡，且属于「魔界台本」系列（0x20ec）。
function c15308295.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec)
end
-- 控制权转移诱发效果的目标函数：必发且不取对象，合法检查直接返回true；操作信息标明要从这张卡原本持有者的魔陷区破坏1张卡。
function c15308295.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏范围是这张卡原本持有者（GetOwner）的魔法与陷阱区域，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,e:GetHandler():GetOwner(),LOCATION_SZONE)
end
-- 效果处理：从原本持有者p的魔陷区中筛选出盖放的「魔界台本」魔法卡；若存在且p在询问中选择“是”，则从中选1张以效果破坏，对应“可以选……破坏”的可选处理。
function c15308295.desop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	-- 取得原本持有者p的魔陷区中所有符合条件的盖放「魔界台本」魔法卡，存入组g。
	local g=Duel.GetMatchingGroup(c15308295.desfilter,p,LOCATION_SZONE,0,nil)
	-- 仅当存在可选对象且原本持有者p确认要执行破坏（选择“是”）时才继续；体现“可以选……破坏”的选择权。
	if g:GetCount()>0 and Duel.SelectYesNo(p,aux.Stringid(15308295,3)) then  --"是否选「魔界台本」魔法卡破坏？"
		-- 向原本持有者p显示选择破坏对象的提示，提示语为“请选择要破坏的卡”。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(p,1,1,nil)
		-- 以效果原因破坏选中的那张「魔界台本」魔法卡。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
