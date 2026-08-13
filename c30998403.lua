--DDD天空王ゼウス・ラグナロク
-- 效果：
-- 「DD」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1张「DD」卡或「契约书」卡为对象才能发动。那张卡破坏。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「DD」怪兽灵摆召唤。
-- ②：对方把手卡的怪兽的效果发动时，从自己墓地把1只「DD」怪兽和1张「契约书」卡除外才能发动。那个发动无效。
local s,id,o=GetID()
-- 初始化函数：为卡片注册连接召唤手续（2只以上DD怪兽）、①的起动效果（取对象破坏并追加灵摆召唤）和②的诱发即时效果（无效对方手卡怪兽效果发动），并设置前者为1回合1次。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只以上「DD」怪兽作为连接素材（0xaf为DD）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xaf),2)
	c:EnableReviveLimit()
	-- 对应①效果：以自己场上1张「DD」卡或「契约书」卡为对象才能发动，那张卡破坏；这个回合自己在通常灵摆召唤外加上只有1次，主要阶段可以把「DD」怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏并获得额外灵摆"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 对应②效果：对方把手卡的怪兽的效果发动时，从自己墓地除外1只「DD」怪兽和1张「契约书」卡才能发动，那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 定义①的选择对象过滤条件：表侧表示且属于「DD」（0xaf）或「契约书」（0xae）字段。
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf,0xae)
end
-- ①的发动目标处理：确认本回合还没使用过额外灵摆效果，且存在可选择的自己场上的DD/契约书卡，然后选择1张作为对象并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 发动合法性检查：本回合未使用过①的额外灵摆效果（flag为0），且自己场上有表侧表示的「DD」卡或「契约书」卡可以作为对象。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出选择提示信息，告知玩家需要选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上的表侧「DD」卡或「契约书」卡中选择1张作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将本次连锁的操作信息设置为“破坏1张卡”，供相关效果（如星尘龙）进行连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①的处理：破坏所选对象；若本回合尚未获得追加灵摆召唤的效果，则给己方注册一个额外灵摆召唤效果并登记flag，使本回合可以进行一次DD怪兽的追加灵摆召唤。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡仍与当前连锁相关（没有被无效或转移），则将其破坏。
	if tc:IsRelateToChain() then Duel.Destroy(tc,REASON_EFFECT) end
	-- 检查己方是否已获得过本回合的额外灵摆召唤效果标识，没有才继续注册该效果，避免重复获得追加灵摆召唤机会。
	if Duel.GetFlagEffect(tp,id)==0 then
		-- 这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「DD」怪兽灵摆召唤。②：对方把手卡的怪兽的效果发动时，从自己墓地把1只「DD」怪兽和1张「契约书」卡除外才能发动，那个发动无效。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"使用「DDD 天空王 宙斯末日神」的效果灵摆召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCountLimit(1,id+o)
		e1:SetValue(s.pendvalue)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 把额外灵摆召唤效果注册到玩家tp，使tp在本回合可以额外进行1次DD怪兽的灵摆召唤。
		Duel.RegisterEffect(e1,tp)
		-- 为tp登记一个flag（code=id），标记本回合已经使用过①的额外灵摆召唤效果，防止同一回合重复获得。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 定义追加灵摆召唤可适用的怪兽范围：只有「DD」怪兽（0xaf）才能通过这个额外灵摆召唤效果出场。
function s.pendvalue(e,c)
	return c:IsSetCard(0xaf)
end
-- ②的发动条件：对方在手卡发动怪兽效果，且该发动处于可被无效的连锁中时，本卡才能发动②。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置，用于判断对方是不是在手卡发动效果。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 条件判断：连锁发起者是对方（ep==1-tp）、触发位置为手卡、效果类型为怪兽效果，且该连锁可以被无效。
	return ep==1-tp and loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义②的cost检索过滤：从自己墓地选择可以作为cost除外的卡，包括「DD」怪兽和「契约书」卡。
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost() and
		(c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0xae))
end
-- 定义cost候选过滤1：自己墓地的「DD」怪兽且可以除外作为cost。
function s.cfilter1(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义cost候选过滤2：自己墓地的「契约书」卡且可以除外作为cost。
function s.cfilter2(c)
	return c:IsSetCard(0xae) and c:IsAbleToRemoveAsCost()
end
-- ②的cost处理：从自己墓地选择1只「DD」怪兽和1张「契约书」卡，将它们表侧表示除外作为发动代价。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有可能作为②cost的卡片组（DD怪兽或契约书卡）。
	local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查候选组是否能选出2张卡，分别满足DD怪兽和契约书的组合（顺序不限）。
	if chk==0 then return rg:CheckSubGroup(aux.gffcheck,2,2,s.cfilter1,nil,s.cfilter2,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地候选中选出2张卡，其中1只为DD怪兽、1张为契约书卡，作为除外cost。
	local g=rg:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.cfilter1,nil,s.cfilter2,nil)
	-- 将选出的cost卡表侧表示除外，完成②的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②的目标处理：没有额外选择目标，仅设置操作信息，效果处理时无效对方那次发动。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明要将当前连锁的对方效果发动无效化（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②的效果处理：直接无效对方那个效果的发动。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效操作，使当前连锁ev的发动无效。
	Duel.NegateActivation(ev)
end
