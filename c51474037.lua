--ヤモイモリ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以把墓地的这张卡除外，以自己场上1只爬虫类族怪兽和对方场上1只表侧表示怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽变成里侧守备表示。
-- ●作为对象的自己怪兽破坏，作为对象的对方怪兽的攻击力直到回合结束时变成0。
function c51474037.initial_effect(c)
	-- “这个卡名的效果1回合只能使用1次。①：可以把墓地的这张卡除外，以自己场上1只爬虫类族怪兽和对方场上1只表侧表示怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽变成里侧守备表示。●作为对象的自己怪兽破坏，作为对象的对方怪兽的攻击力直到回合结束时变成0。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,51474037)
	-- 设置效果的发动代价为把墓地中的这张卡除外（通过 aux.bfgcost 辅助函数实现），对应“可以把墓地的这张卡除外”的发动条件。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c51474037.target)
	e1:SetOperation(c51474037.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上的表侧表示爬虫类族怪兽，要求该怪兽能成为对象，且对方场上有满足条件的表侧表示怪兽可作为第二对象（根据该怪兽能否变成里侧表示来确定第二对象的可选条件）。
function c51474037.filter1(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
		-- 并且对方场上存在1只表侧表示怪兽能作为第二对象，其过滤条件由 filter2 决定，check 参数为当前自己怪兽能否变成里侧表示。
		and Duel.IsExistingTarget(c51474037.filter2,tp,0,LOCATION_MZONE,1,nil,c:IsCanTurnSet())
end
-- 过滤对方场上的表侧表示怪兽作为第二对象：它必须能变成里侧守备表示（当第一对象能变成里侧时），或者其攻击力大于0，以保证至少可选择“变里侧”或“攻击力变0”中的一种后续处理。
function c51474037.filter2(c,check)
	return c:IsFaceup() and (check and c:IsCanTurnSet() or c:GetAttack()>0)
end
-- 效果发动时的目标选择与分支选择：先选择自己场上1只表侧爬虫类族怪兽，再选择对方场上1只表侧表示怪兽；随后根据两只怪兽的状态显示可选选项（变里侧或攻击力变0），记录所选分支，并设置对应的效果分类与操作信息。
function c51474037.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己场上有满足 filter1 的目标（即存在符合条件的自己怪兽和对应的对方怪兽可作为对象），否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51474037.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家显示“请选择效果的对象”的提示信息，准备选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的1只表侧爬虫类族怪兽作为第一对象，并将其登记为当前连锁的目标。
	local g1=Duel.SelectTarget(tp,c51474037.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	local check=tc1:IsCanTurnSet()
	e:SetLabelObject(tc1)
	-- 再次显示“请选择效果的对象”提示，准备选择对方场上的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上的1只表侧表示怪兽作为第二对象，check 参数传入第一对象是否能变成里侧表示，用于过滤可选的第二对象。
	local g2=Duel.SelectTarget(tp,c51474037.filter2,tp,0,LOCATION_MZONE,1,1,nil,check)
	local sel
	local tc2=g2:GetFirst()
	if tc2:IsAttack(0) then
		-- 当对方怪兽攻击力为0时，唯一可用的分支是“变成里侧守备表示”，因此只显示该选项并选择它（sel=0）。
		sel=Duel.SelectOption(tp,aux.Stringid(51474037,0))  --"变成里侧守备表示"
	elseif not (check and tc2:IsCanTurnSet()) then
		-- 当不能选择“变成里侧守备表示”时，只能选择“攻击力变成0”分支；通过 +1 将选项序号转换为该分支的标记（sel=1）。
		sel=Duel.SelectOption(tp,aux.Stringid(51474037,1))+1  --"攻击力变成0"
	else
		-- 当两个分支都可用时，让玩家从“变成里侧守备表示”和“攻击力变成0”中选择一个，返回的序号直接作为分支标记。
		sel=Duel.SelectOption(tp,aux.Stringid(51474037,0),aux.Stringid(51474037,1))  --"变成里侧守备表示/攻击力变成0"
	end
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
		g1:Merge(g2)
		-- 设置当前连锁的操作信息为“改变表示形式”（CATEGORY_POSITION），目标为选中的两只怪兽（已合并），数量记为1。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置当前连锁的操作信息为“破坏”（CATEGORY_DESTROY），目标为自己场上选中的爬虫类族怪兽（将因效果被破坏），数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	end
end
-- 效果处理：根据之前选择的分支执行；sel=0时将仍与效果相关的目标怪兽全部变成里侧守备表示；sel=1时破坏自己怪兽，成功后再将对方怪兽的攻击力变为0直到回合结束。
function c51474037.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时的目标卡片组（包括第一对象和第二对象），便于后续判断与操作。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sel=e:GetLabel()
	if sel==0 then
		local tg=g:Filter(Card.IsRelateToEffect,nil,e)
		-- 将筛选出的仍与效果相关的对象怪兽全部变成里侧守备表示。
		Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
	else
		local tc1=e:GetLabelObject()
		local tc2=g:GetFirst()
		if tc2==tc1 then tc2=g:GetNext() end
		-- 先判断自己怪兽仍与效果相关，且被效果成功破坏（Duel.Destroy 返回值不为0），并且对方怪兽仍与效果相关，满足这些条件才执行攻击力变0的处理。
		if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2 and tc2:IsRelateToEffect(e) then
			-- 作为对象的对方怪兽的攻击力直到回合结束时变成0。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
		end
	end
end
