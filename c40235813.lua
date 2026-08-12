--時の黒魔術師
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●除「时间黑魔术师」外的1张有「时间黑魔术师」的卡名记述的卡从卡组加入手卡。这个回合的结束阶段，从自己墓地把1张「时间黑魔术师」加入手卡。
-- ●进行1次投掷硬币，对里表作猜测。猜中的场合，对方场上的怪兽全部破坏，给与对方那个原本攻击力合计数值一半的伤害。猜错的场合，自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化效果：注册卡的卡名记述列表，并创建一张可以在自由时点发动的通常魔法式起动效果，设置其效果分类、提示时点、目标函数与处理函数后注册给这张卡。
function s.initial_effect(c)
	-- 把这张卡自身登记为「卡名记述着『时间黑魔术师』的卡」，使 aux.IsCodeListed 能对这张卡返回真。
	aux.AddCodeList(c,id)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_COIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义检索用过滤函数：筛选卡组中可以加入手卡、且卡名记述着「时间黑魔术师」的这张卡以外的卡。
function s.thfilter(c)
	-- 返回真当且仅当：这张卡不是「时间黑魔术师」本身、效果文本记述着「时间黑魔术师」的卡名、并且可以加入手卡。
	return not c:IsCode(id) and aux.IsCodeListed(c,id) and c:IsAbleToHand()
end
-- 目标函数：先分别检查两个选项（卡组检索、投掷硬币）是否可用，发动可能时要求至少一项可用，再让玩家选择其中一项，按所选分支设置效果分类、1回合1次的标记以及操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以加入手卡、记述着「时间黑魔术师」卡名的卡，作为选项1（检索）可用的条件。
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 选项1还需满足：不是发动代价检查阶段，或者本回合尚未使用过选项1的效果（1回合1次的限制）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查双方场上是否存在至少1只怪兽，作为选项2（投掷硬币破坏）可用的条件。
	local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 选项2还需满足：不是发动代价检查阶段，或者本回合尚未使用过选项2的效果（1回合1次的限制）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	-- 让玩家在可用选项中选择要发动的效果（检索或投掷硬币）。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索"
			{b2,aux.Stringid(id,2),2})  --"投掷硬币"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
			-- 为玩家注册本回合结束阶段前有效的标记效果，记录选项1的效果本回合已经使用过（用于1回合1次的判定）。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：本次连锁将从卡组把1张卡加入手卡（供发动时的连锁检测等使用）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_COIN)
			-- 为玩家注册本回合结束阶段前有效的标记效果，记录选项2的效果本回合已经使用过（用于1回合1次的判定）。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 取得双方场上的全部怪兽，作为破坏效果可能影响的范围。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置操作信息：本次连锁的破坏效果将处理场上怪兽中的1张以上（供发动时的连锁检测等使用）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		-- 设置操作信息：本次连锁包含1次投掷硬币的处理。
		Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	end
end
-- 定义攻击力合计用过滤函数：排除原本攻击力为负的怪兽，并确认该怪兽属于本次破坏效果所覆盖的范围。
function s.calfilter(c)
	if c:GetTextAttack()<0 then return false end
	-- 检查该怪兽是否仍处于本次效果处理的覆盖范围内（用于确定应计入原本攻击力合计的被破坏怪兽）。
	return aux.covcheck(c)
end
-- 处理函数：若选择检索，则从卡组选1张记述着「时间黑魔术师」卡名的卡加入手卡并让对方确认，再注册一个在结束阶段从自己墓地把1张「时间黑魔术师」加入手卡的延时效果；若选择投掷硬币，则让玩家猜测硬币正反面并投掷1次，猜中破坏对方场上全部怪兽并给与对方原本攻击力合计一半的伤害，猜错破坏自己场上全部怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 向发动方提示「请选择要加入手牌的卡」的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让发动方从自己卡组选择1张「时间黑魔术师」以外、卡名记述着「时间黑魔术师」且可以加入手卡的卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡以效果处理的原因加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示刚加入手卡的卡进行确认。
			Duel.ConfirmCards(1-tp,g)
		end
		-- ●除「时间黑魔术师」外的1张有「时间黑魔术师」的卡名记述的卡从卡组加入手卡。这个回合的结束阶段，从自己墓地把1张「时间黑魔术师」加入手卡。●进行1次投掷硬币，对里表作猜测。猜中的场合，对方场上的怪兽全部破坏，给与对方那个原本攻击力合计数值一半的伤害。猜错的场合，自己场上的怪兽全部破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.thop2)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 把这个结束阶段触发的延时效果注册为全局环境效果，使其在回合结束阶段执行从墓地回收的处理。
		Duel.RegisterEffect(e1,tp)
	elseif e:GetLabel()==2 then
		local p=1-tp
		-- 向发动方提示「请选择硬币的正反面」的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 让发动方宣言猜测的硬币面（正面或反面）。
		local coin=Duel.AnnounceCoin(tp)
		-- 进行1次投掷硬币，记录投掷结果。
		local res=Duel.TossCoin(tp,1)
		if coin==res then
			p=tp
		end
		-- 取得被破坏一方（猜中为对方、猜错为自己）场上的全部怪兽。
		local sg=Duel.GetMatchingGroup(aux.TRUE,p,LOCATION_MZONE,0,nil)
		local cg=sg:Filter(s.calfilter,nil)
		-- 以效果处理的原因破坏这组怪兽，若实际破坏数量为0则不进行后续伤害处理。
		if Duel.Destroy(sg,REASON_EFFECT)~=0 then
			-- 取得刚才破坏处理中实际被破坏的怪兽组。
			local og=Duel.GetOperatedGroup()
			if og:GetCount()>0 and p==1-tp then
				-- 给与对方被破坏怪兽原本攻击力合计数值一半（向上取整）的效果伤害。
				Duel.Damage(1-tp,math.ceil((og&cg):GetSum(Card.GetTextAttack,nil)/2),REASON_EFFECT)
			end
		end
	end
end
-- 定义墓地回收用过滤函数：筛选可以加入手卡的「时间黑魔术师」。
function s.thfilter2(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
-- 结束阶段的延时处理：显示卡片动画，让玩家从自己墓地选1张「时间黑魔术师」加入手卡，并向对方确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡的卡片动画，提示当前进行的是不入连锁的结束阶段处理。
	Duel.Hint(HINT_CARD,0,id)
	-- 向发动方提示「请选择要加入手牌的卡」的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动方从自己墓地选择1张不受「王家长眠之谷」影响、可以加入手卡的「时间黑魔术师」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果处理的原因加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚加入手卡的卡进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
