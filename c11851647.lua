--ハイ・キューピット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的等级直到回合结束时上升因为这个效果发动而送去墓地的卡数量的数值。
-- ②：场上的这张卡被对方破坏送去墓地的场合发动。自己回复1500基本分。
function c11851647.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的等级直到回合结束时上升因为这个效果发动而送去墓地的卡数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11851647,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11851647)
	e1:SetCost(c11851647.lvcost)
	e1:SetOperation(c11851647.lvop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方破坏送去墓地的场合发动。自己回复1500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11851647,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,11851648)
	e2:SetCondition(c11851647.reccon)
	e2:SetTarget(c11851647.rectg)
	e2:SetOperation(c11851647.recop)
	c:RegisterEffect(e2)
end
-- ①效果发动代价：从自己卡组上面选择1~3张（最多3张）卡送去墓地，并把实际送墓数量记录在效果标签中，用于后续提升等级。
function c11851647.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定：确认玩家能否将卡组最上方1张卡作为代价送去墓地，即至少能送1张才可发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=3,1,-1 do
		-- 依次检查1到3张中哪些数量可以作为代价把卡组顶端对应数量的卡送去墓地，构造出发动时可选择的数量列表。
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 当只有1张可选时（即可选数量必为1），直接以代价方式从卡组顶把1张卡送去墓地并记录数量。
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
		e:SetLabel(1)
	else
		-- 向玩家显示选择提示，请其选择要送去墓地的卡数量。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11851647,2))  --"请选择要送去墓地的数量"
		-- 让玩家在可选数量中宣言一个数字ac，作为实际从卡组顶送去墓地的卡数。
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 以代价方式从卡组顶把玩家选择的数量ac张卡送去墓地。
		Duel.DiscardDeck(tp,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
-- ①效果处理：若这张卡仍表侧表示且与效果关联，则根据代价阶段记录的送墓数量，给它附加一个直到结束阶段为止的等级上升效果。
function c11851647.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		-- 这张卡的等级直到回合结束时上升因为这个效果发动而送去墓地的卡数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct)
		c:RegisterEffect(e1)
	end
end
-- ②效果发动条件判定：这张卡从场上被对方破坏并送去墓地时满足条件，即破坏方为对方玩家、破坏原因为破坏且此前位于场上。
function c11851647.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and bit.band(r,REASON_DESTROY)~=0 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的目标/操作信息设定：将回复对象玩家设为自己，回复量设为1500，并通知系统本连锁将进行回复效果处理。
function c11851647.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自己（回复基本分的对象）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1500，作为后续回复的数值。
	Duel.SetTargetParam(1500)
	-- 向系统登记恢复类操作信息：将由tp玩家回复1500基本分；targets为nil，因为回复对象是玩家而非卡片。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
-- ②效果处理：从连锁信息中取得对象玩家和回复数值，使该玩家回复相应基本分。
function c11851647.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中记录的对象玩家p和对象参数d（回复量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p回复d点基本分，回复原因是效果；若受回复变化等效果影响，实际回复值可能不同。
	Duel.Recover(p,d,REASON_EFFECT)
end
