--死のマジック・ボックス
-- 效果：
-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。那只对方怪兽破坏。那之后，那只自己怪兽的控制权移给对方。
function c25774450.initial_effect(c)
	-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。那只对方怪兽破坏。那之后，那只自己怪兽的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25774450.target)
	e1:SetOperation(c25774450.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选可作为破坏对象的对方怪兽，要求该怪兽离开后对方场上仍有可用的怪兽区，以便后续控制权转移能成功。
function c25774450.filter(c,tp)
	-- 计算把怪兽c移出后，对方玩家tp的可用主要怪兽区数量是否大于0，确保有空格接收控制权。
	return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 发动时判定与取对象选择：效果只能在满足“对方场上有可破坏且破坏后留空位的怪兽”且“自己场上有可改变控制权的怪兽”时发动；发动时玩家需分别选择对方怪兽（破坏）和自己怪兽（控制权转移）。
function c25774450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只符合filter的怪兽（即以该怪兽为破坏对象时，破坏后对方场上仍有空位）。
	if chk==0 then return Duel.IsExistingTarget(c25774450.filter,tp,0,LOCATION_MZONE,1,nil,1-tp)
		-- 检查自己场上是否存在至少1只能够改变控制权的怪兽，作为控制权转移的合法对象。
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只符合filter的怪兽作为取对象目标（将被破坏），并将其登记为本连锁的对象。
	local g1=Duel.SelectTarget(tp,c25774450.filter,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	-- 向发动玩家显示“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从自己场上选择1只能够改变控制权的怪兽作为取对象目标（控制权将转移给对方），并登记为对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记破坏的操作信息：本连锁将破坏1张卡（g1），供其他卡检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 登记控制权转移的操作信息：本连锁将改变1张卡的控制权（g2），供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g2,1,0,0)
end
-- 效果处理：先取出破坏对象和控制权对象；若破坏对象仍在场且被效果成功破坏，再处理控制权转移；若控制权对象仍关联且在场，则通过BreakEffect使控制权转移作为后续独立处理，最后把己方怪兽控制权交给对方。
function c25774450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从操作信息中取得破坏类别对应的目标组dg，即之前选定的对方怪兽。
	local ex1,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 从操作信息中取得控制权类别对应的目标组cg，即之前选定的自己怪兽。
	local ex2,cg=Duel.GetOperationInfo(0,CATEGORY_CONTROL)
	local dc=dg:GetFirst()
	local cc=cg:GetFirst()
	-- 确认破坏对象仍与效果关联，并且被效果成功破坏（返回数非0），才继续执行后续控制权转移。
	if dc:IsRelateToEffect(e) and Duel.Destroy(dc,REASON_EFFECT)~=0 then
		if cc:IsRelateToEffect(e) then
			-- 中断当前连锁处理，让后续的控制权转移不与被破坏处理视为同时进行，以符合“那之后”的时点关系。
			Duel.BreakEffect()
			-- 将之前选定的己方怪兽cc的控制权转移给对方玩家（1-tp），完成卡牌效果。
			Duel.GetControl(cc,1-tp)
		end
	end
end
