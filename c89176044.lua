--捕食原生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把「捕食原生」以外的1张「捕食」卡送去墓地才能发动。从卡组把1张「融合」魔法卡加入手卡。这张卡的发动后，直到回合结束时自己不是龙族·植物族怪兽不能特殊召唤。
-- ②：对方场上有怪兽特殊召唤的场合，把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果的发动和②效果的墓地诱发效果。
function s.initial_effect(c)
	-- 注册一个用于检测此卡是否已在墓地的状态标记效果，用于后续墓地效果的发动条件判定。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：从卡组把「捕食原生」以外的1张「捕食」卡送去墓地才能发动。从卡组把1张「融合」魔法卡加入手卡。这张卡的发动后，直到回合结束时自己不是龙族·植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方场上有怪兽特殊召唤的场合，把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.descon)
	-- 设置发动成本为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可加入手卡的「融合」魔法卡。
function s.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤条件：卡组中除「捕食原生」以外的「捕食」卡，且送去墓地作为cost后卡组仍有可检索的「融合」魔法卡。
function s.costfilter(c,tp)
	return not c:IsCode(id) and c:IsSetCard(0xf3) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在至少1张可检索的「融合」魔法卡（排除作为cost送墓的那张卡）。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- ①效果的发动成本处理：从卡组选择1张「捕食原生」以外的「捕食」卡送去墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查卡组中是否存在满足送墓条件的「捕食」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 给玩家发送提示信息：“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「捕食」卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 将选择的卡作为发动成本送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动目标判定与操作信息注册。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查卡组中是否存在可检索的「融合」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际效果处理：检索「融合」魔法卡，并适用特殊召唤限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「融合」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是龙族·植物族怪兽不能特殊召唤。②：对方场上有怪兽特殊召唤的场合，把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。那只怪兽破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制特殊召唤的玩家效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制特殊召唤的过滤函数：不能特殊召唤龙族·植物族以外的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PLANT+RACE_DRAGON)
end
-- 过滤条件：对方场上特殊召唤的怪兽（排除因当前效果自身导致的时点重叠）。
function s.spfilter2(c,tp,se)
	return c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：对方场上有怪兽特殊召唤的场合。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter2,1,nil,1-tp,se)
end
-- 过滤条件：自己场上表侧表示的融合怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- ②效果的发动目标判定与对象选择。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc) end
	-- 步骤0：检查自己场上是否存在可作为对象的表侧表示融合怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的融合怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理的操作信息：破坏选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的实际效果处理：破坏作为对象的融合怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将作为对象的怪兽因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
