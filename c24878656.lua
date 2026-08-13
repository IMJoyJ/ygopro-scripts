--トイ・ボックス
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●从自己的手卡·卡组·怪兽区域（表侧表示）·墓地选原本卡名包含「玩具」的持有可以把自身当作魔法卡使用从手卡到魔法与陷阱区域盖放效果的最多2只怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
-- ●自己的魔法与陷阱区域最多2张卡破坏。
-- ②：1回合1次，对方怪兽的攻击宣言时，把自己场上1张里侧表示卡送去墓地才能发动。那只对方怪兽破坏。
local s,id,o=GetID()
-- 为「玩具箱子」注册全部效果：e1为魔法卡激活用空效果；e2为①的“盖放怪兽”选项（起动效果，1回合1次，与e3共用次数）；e3为①的“破坏自己的魔法与陷阱区域卡”选项（e2的克隆，共用次数）；e4为②对方怪兽攻击宣言时的诱发效果（破坏攻击怪兽，1回合1次）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以从以下效果选择1个发动。●从自己的手卡·卡组·怪兽区域（表侧表示）·墓地选原本卡名包含「玩具」的持有可以把自身当作魔法卡使用从手卡到魔法与陷阱区域盖放效果的最多2只怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"盖放怪兽"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))  --"破坏自己魔法陷阱区域的卡"
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，对方怪兽的攻击宣言时，把自己场上1张里侧表示卡送去墓地才能发动。那只对方怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.dmcon)
	e4:SetCost(s.dmcost)
	e4:SetTarget(s.dmtg)
	e4:SetOperation(s.dmop)
	c:RegisterEffect(e4)
end
-- 过滤条件：选择卡片需为怪兽、属于「玩具」系列（0x1a8）、可以被S盖放（IsSSetable）、拥有“可以当作魔法卡盖放”的标志（set_as_spell），且若在怪兽区域需为表侧表示（IsFaceupEx）。
function s.stfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a8) and c:IsSSetable()
		and c.set_as_spell and c:IsFaceupEx()
end
-- e2的发动条件：检查自己的手卡·卡组·表侧怪兽区域·墓地中是否存在至少1张满足s.stfilter的怪兽；存在才能发动。
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：在chk==0时，确认上述区域有符合条件的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
end
-- ①盖放效果处理：提示选择要盖放的卡；计算可盖放数量为魔陷区空格与2的较小值；从手卡·卡组·表侧怪兽区域·墓地选择1~ct张符合条件的怪兽（墓地卡还需通过王家长眠之谷过滤），然后通过SSet当作魔法卡盖放到自己的魔法与陷阱区域。
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示“请选择要盖放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 计算本效果最多能盖放的数量：取自己魔法与陷阱区域的空位数和2中的较小值。
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
	-- 选择1到ct张满足s.stfilter的怪兽，范围为自己的手卡·卡组·表侧怪兽区域·墓地；使用aux.NecroValleyFilter过滤掉受王家长眠之谷影响而无法从墓地特殊使用的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的怪兽当作魔法卡在自己的魔法与陷阱区域里侧表示盖放。
	Duel.SSet(tp,g)
end
-- 筛选自己魔法与陷阱区域中可被破坏的卡：GetSequence()<5表示位于5个主要魔陷区，排除场地区（序列5），即只选择通常的魔法与陷阱区域。
function s.desfilter(c)
	return c:GetSequence()<5
end
-- ①的“破坏自己魔陷区”选项（对应原文‘●自己的魔法与陷阱区域最多2张卡破坏。’）目标判定：发动时直接合法；随后获取自己魔陷区中所有满足s.desfilter的卡，若存在则设置破坏操作信息（数量按1设置，实际可选1~2张）。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己魔法与陷阱区域中所有位于主要魔陷区的卡（排除场地魔法区域），作为可能被破坏的候选集合。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
	if g:GetCount()>0 then
		-- 设置当前连锁的操作信息：包含破坏分类，目标候选为g，预计破坏数量为1，用于连锁检测（如星尘龙等）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- ①破坏效果处理：重新获取当前魔陷区可破坏的卡，提示选择1到2张，然后以效果原因将它们破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取当前可破坏的自己魔陷区卡集合，因为发动后卡的数量可能发生变化。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
	if g:GetCount()>0 then
		-- 给操作者显示“请选择要破坏的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,2,nil)
		-- 将玩家选中的1~2张卡以效果原因（REASON_EFFECT）破坏并送入墓地。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- ②的发动条件：效果仅能在对方回合且对方怪兽攻击宣言时发动，通过判断tp不是当前回合玩家来确认。
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果发动者不是当前回合玩家，即必须是在对方回合满足条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 代价筛选：选择自己场上的里侧表示卡，且该卡可以作为代价送去墓地。
function s.cfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToGraveAsCost()
end
-- ②的代价处理：从自己场上选择1张里侧表示卡（排除玩具箱子自身），将其作为代价送去墓地，随后才能处理效果。
function s.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价合法性检查：确认自己场上存在至少1张满足s.cfilter的里侧表示卡（排除c），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,tp) end
	-- 给操作者显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张里侧表示卡（排除效果持有者c）作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	-- 将选择的里侧表示卡以代价原因（REASON_COST）送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②的发动目标：取得攻击宣言的对方怪兽，确认其仍在场上后将其设为效果对象，并设置破坏操作信息。
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的怪兽（即要破坏的对象）。
	local ac=Duel.GetAttacker()
	if chk==0 then return ac:IsOnField() end
	-- 将攻击怪兽设置为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(ac)
	-- 设置操作信息：本连锁将破坏对象ac，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ac,1,0,0)
end
-- ②效果处理：取出对象攻击怪兽，若其仍与效果相关、控制者仍为对方且是怪兽，则将其破坏。
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回效果处理时记录的对象（攻击怪兽）。
	local ac=Duel.GetFirstTarget()
	if ac:IsRelateToEffect(e) and ac:IsControler(1-tp) and ac:IsType(TYPE_MONSTER) then
		-- 将对象怪兽以效果原因破坏。
		Duel.Destroy(ac,REASON_EFFECT)
	end
end
