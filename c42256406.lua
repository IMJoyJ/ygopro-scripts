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
-- 判断是否可以发动效果，条件是该卡处于攻击表示。
function c42256406.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置连锁操作信息，表示将要改变该卡的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 将该卡从攻击表示变为守备表示。
function c42256406.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 改变该卡的表示形式为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判断是否可以发动效果，条件是攻击对象不是该卡且攻击对象为己方场上表侧表示的怪兽。
function c42256406.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and c~=bt and bt:IsFaceup() and bt:GetControler()==c:GetControler()
end
-- 判断是否可以发动效果，条件是该卡可以被选为攻击对象。
function c42256406.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断该卡是否可以被选为攻击对象。
	if chk==0 then return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler()) end
end
-- 将攻击对象转移为该卡。
function c42256406.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否有效且攻击怪兽未免疫该效果。
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象改变为该卡。
		Duel.ChangeAttackTarget(c)
	end
end
-- 设置发动cost，允许玩家从卡组顶部丢弃1~3张卡。
function c42256406.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以作为cost丢弃1张卡。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=3,1,-1 do
		-- 检查玩家是否可以作为cost丢弃i张卡。
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 将玩家卡组顶部的ct[1]张卡送去墓地。
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
		e:SetLabel(1)
	else
		-- 提示玩家选择要送去墓地的卡的数量。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(42256406,3))  --"请选择要送去墓地的卡的数量"
		-- 让玩家宣言要丢弃的卡的数量。
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 将玩家卡组顶部的ac张卡送去墓地。
		Duel.DiscardDeck(tp,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
-- 为该卡添加一个守备力提升效果。
function c42256406.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		-- 为该卡添加一个守备力提升效果，提升值为丢弃卡数乘以500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		c:RegisterEffect(e1)
	end
end
