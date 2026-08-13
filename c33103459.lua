--EMコン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以这张卡以外的自己场上1只攻击力1000以下的「娱乐伙伴」怪兽为对象才能发动。自己场上的同是表侧攻击表示的那只怪兽和这张卡变成守备表示，从卡组把1只「异色眼」怪兽加入手卡。
-- ②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小角」以外的「娱乐伙伴」怪兽除外才能发动。自己回复500基本分。
function c33103459.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以这张卡以外的自己场上1只攻击力1000以下的「娱乐伙伴」怪兽为对象才能发动。自己场上的同是表侧攻击表示的那只怪兽和这张卡变成守备表示，从卡组把1只「异色眼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33103459,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33103459.thcon)
	e1:SetTarget(c33103459.thtg)
	e1:SetOperation(c33103459.thop)
	c:RegisterEffect(e1)
	-- ②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小角」以外的「娱乐伙伴」怪兽除外才能发动。自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33103459,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c33103459.lpcon)
	e2:SetCost(c33103459.lpcost)
	e2:SetTarget(c33103459.lptg)
	e2:SetOperation(c33103459.lpop)
	c:RegisterEffect(e2)
	if not c33103459.global_check then
		c33103459.global_check=true
		-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以这张卡以外的自己场上1只攻击力1000以下的「娱乐伙伴」怪兽为对象才能发动。自己场上的同是表侧攻击表示的那只怪兽和这张卡变成守备表示，从卡组把1只「异色眼」怪兽加入手卡。②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小角」以外的「娱乐伙伴」怪兽除外才能发动。自己回复500基本分。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(33103459)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置ge1在通常召唤成功事件触发时执行的操作函数为aux.sumreg，用于在该卡召唤成功时打上标记，以满足①的“召唤·特殊召唤成功的回合”条件。
		ge1:SetOperation(aux.sumreg)
		-- 将ge1作为全场效果注册到玩家0，监听场上所有怪兽的通常召唤成功，配合aux.sumreg给本卡添加召唤成功标记。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(33103459)
		-- 将ge2（ge1的克隆，改为监听特殊召唤成功）注册为全场效果，同样在特殊召唤成功时给本卡添加特殊召唤成功标记。
		Duel.RegisterEffect(ge2,0)
	end
end
-- ①的发动条件：检查本卡是否带有33103459标记（即本回合召唤或特殊召唤成功过），有则条件成立。
function c33103459.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(33103459)~=0
end
-- 定义①的对象选择过滤器：选择自己场上表侧攻击表示、攻击力1000以下、属于「娱乐伙伴」且能变更表示形式的怪兽（不包括本卡）。
function c33103459.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsAttackBelow(1000)
		and c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 定义①的检索过滤器：选择卡组中属于「异色眼」系列且能够加入手卡的怪兽。
function c33103459.thfilter(c)
	return c:IsSetCard(0x99) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①的发动目标处理：若在连锁中检查对象则验证指定卡是否合法；若为发动前合法性检查，则确认卡组有可检索的「异色眼」怪兽、本卡处于表侧攻击表示且场上有可选目标。
function c33103459.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33103459.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查卡组中是否存在至少1张满足thfilter的「异色眼」怪兽，保证有卡可检索。
	if chk==0 then return Duel.IsExistingMatchingCard(c33103459.thfilter,tp,LOCATION_DECK,0,1,nil)
		and e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
		-- 同时检查场上是否存在至少1张满足filter的「娱乐伙伴」怪兽（本卡除外）可作为取对象目标。
		and Duel.IsExistingTarget(c33103459.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 发动时选择1只符合条件的自己场上的「娱乐伙伴」怪兽（本卡除外）作为①的对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c33103459.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本效果将进行从卡组把1张卡加入手卡的处理，检索来源为卡组，操作玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：若本卡和对象卡都仍与效果关联、均为表侧攻击表示且控制权为tp，则把两张卡都变为表侧守备表示；若成功，则从卡组选1张「异色眼」怪兽加入手卡并向对方展示。
function c33103459.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出①发动时选择的对象怪兽（即那只「娱乐伙伴」怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsControler(tp)
		and tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsControler(tp)
		-- 将本卡和对象怪兽同时变为表侧守备表示，并确认变更数量为2（两张都成功变更）后才继续检索处理。
		and Duel.ChangePosition(Group.FromCards(c,tc),POS_FACEUP_DEFENSE)==2 then
		-- 从卡组选择要加入手牌的卡之前，给tp弹出“请选择要加入手牌的卡”的提示并缓存选择消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足thfilter的「异色眼」怪兽。
		local g=Duel.SelectMatchingCard(tp,c33103459.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「异色眼」怪兽以效果原因加入持有者手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 把加入手卡的「异色眼」怪兽展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义②的代价过滤器：选择墓地中属于「娱乐伙伴」、是怪兽、能除外作为代价、且卡名不是本卡的卡。
function c33103459.cfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and not c:IsCode(33103459)
end
-- ②的发动条件：当前回合玩家不是tp，即对方回合。
function c33103459.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断当前回合玩家不等于tp，满足“对方回合”的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②的代价判定：本卡自身能从墓地除外，且墓地存在另一只符合条件的「娱乐伙伴」怪兽才可发动；随后选择那只怪兽作为代价。
function c33103459.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在至少1只满足cfilter的「娱乐伙伴」怪兽（排除本卡），作为另一个代价素材。
		and Duel.IsExistingMatchingCard(c33103459.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 选择代价卡前，给tp弹出“请选择要除外的卡”的提示并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足cfilter的「娱乐伙伴」怪兽作为代价素材。
	local g=Duel.SelectMatchingCard(tp,c33103459.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的怪兽与本卡一起以表侧表示除外，作为②发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②的目标设定：无额外对象要求，设置回复对象为tp、回复值为500，并登记操作信息为回复500基本分。
function c33103459.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的回复对象玩家设置为tp，即自己回复基本分。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的回复数值参数设置为500。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本连锁将进行回复500基本分的处理，回复对象为tp，供系统检测和连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ②的效果处理：读取连锁中保存的回复对象和数值，然后执行回复基本分的处理。
function c33103459.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家p（回复对象）和目标参数d（回复值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使玩家p回复d（500）基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
