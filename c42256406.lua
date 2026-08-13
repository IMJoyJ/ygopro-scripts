--カードブロッカー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，变成守备表示。自己场上表侧表示存在的怪兽被选择作为攻击对象时，可以让攻击对象改变为这张卡。这张卡成为攻击对象时，可以把自己卡组的卡从上面最多3张送去墓地。每把1张卡送去墓地，这张卡的守备力直到结束阶段时上升500。
function c42256406.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42256406,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42256406.potg)
	e1:SetOperation(c42256406.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 自己场上表侧表示存在的怪兽被选择作为攻击对象时，可以让攻击对象改变为这张卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42256406,1))  --"改变攻击对象"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c42256406.cbcon)
	e4:SetTarget(c42256406.cbtg)
	e4:SetOperation(c42256406.cbop)
	c:RegisterEffect(e4)
	-- 这张卡成为攻击对象时，可以把自己卡组的卡从上面最多3张送去墓地。每把1张卡送去墓地，这张卡的守备力直到结束阶段时上升500。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42256406,2))  --"守备上升"
	e5:SetCategory(CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	e5:SetCost(c42256406.defcost)
	e5:SetOperation(c42256406.defop)
	c:RegisterEffect(e5)
end
-- 召唤成功时的诱发必发效果，其发动条件判定：若这张卡为表侧攻击表示则条件成立，并设置操作信息为改变表示形式。
function c42256406.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置操作信息：本次处理将改变这张卡的表示形式，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍为表侧攻击表示且与效果关联，则将其变为表侧守备表示。
function c42256406.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式改为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 改变攻击对象效果的发动条件：自己场上表侧表示的其他怪兽被选择为攻击对象，且该攻击对象事件不是由攻击对象变更效果（REASON_REPLACE）造成的，同时此卡与该怪兽为同一控制者。
function c42256406.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and c~=bt and bt:IsFaceup() and bt:GetControler()==c:GetControler()
end
-- 改变攻击对象效果发动时的对象合法性判定：当前攻击怪兽的可攻击对象列表中必须包含这张卡，效果才能发动。
function c42256406.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查攻击怪兽的可攻击对象列表是否包含这张卡，作为发动条件。
	if chk==0 then return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler()) end
end
-- 改变攻击对象效果处理：若这张卡仍与效果关联且攻击怪兽不免疫此效果，则将攻击对象改为这张卡。
function c42256406.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联，并且攻击怪兽不对此效果免疫，以确保转移攻击对象能够生效。
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象改为这张卡。
		Duel.ChangeAttackTarget(c)
	end
end
-- 丢弃卡组效果的发动代价处理：至少能将1张卡从卡组送去墓地；若唯一可行数量为1则直接丢弃1张并记录，否则让玩家在1～3中选择可行的丢弃数量，再按选择丢弃并记录数量。
function c42256406.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能从卡组最上方丢弃1张卡作为发动代价。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=3,1,-1 do
		-- 依次检查丢弃i张卡作为代价是否可行，用于构建可选数量列表。
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 当可行数量唯一时，直接从卡组最上方丢弃该数量的卡作为代价，并记录数量为1。
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
		e:SetLabel(1)
	else
		-- 向玩家显示选择丢弃数量的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(42256406,3))  --"请选择要送去墓地的卡的数量"
		-- 让玩家在可行的数量中宣告一个数字，作为实际丢弃数量。
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 按玩家选择的数量从卡组最上方丢弃相应数量的卡作为代价。
		Duel.DiscardDeck(tp,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
-- 守备力上升效果处理：若这张卡仍为表侧表示且与效果关联，则根据之前记录的丢弃数量，生成使其守备力上升该数量×500的效果，直到结束阶段。
function c42256406.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		-- 每把1张卡送去墓地，这张卡的守备力直到结束阶段时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		c:RegisterEffect(e1)
	end
end
