--ハイ・キューピット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的等级直到回合结束时上升因为这个效果发动而送去墓地的卡数量的数值。
-- ②：场上的这张卡被对方破坏送去墓地的场合发动。自己回复1500基本分。
function c11851647.initial_effect(c)
	-- 效果原文内容：①：从自己卡组上面把最多3张卡送去墓地才能发动。这张卡的等级直到回合结束时上升因为这个效果发动而送去墓地的卡数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11851647,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11851647)
	e1:SetCost(c11851647.lvcost)
	e1:SetOperation(c11851647.lvop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：场上的这张卡被对方破坏送去墓地的场合发动。自己回复1500基本分。
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
-- 函数定义：设置效果①的费用处理函数
function c11851647.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能作为Cost把至少1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=3,1,-1 do
		-- 检查玩家是否能作为Cost把i张卡送去墓地
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 将玩家卡组最上端1张卡送去墓地作为费用
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
		e:SetLabel(1)
	else
		-- 提示玩家选择要送去墓地的卡数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11851647,2))  --"请选择要送去墓地的数量"
		-- 让玩家宣言一个可选的卡数量
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 将玩家卡组最上端宣言数量的卡送去墓地作为费用
		Duel.DiscardDeck(tp,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
-- 函数定义：设置效果①的效果处理函数
function c11851647.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		-- 创建一个等级变更效果，在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct)
		c:RegisterEffect(e1)
	end
end
-- 函数定义：设置效果②的发动条件函数
function c11851647.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and bit.band(r,REASON_DESTROY)~=0 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 函数定义：设置效果②的目标设定函数
function c11851647.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1500
	Duel.SetTargetParam(1500)
	-- 设置连锁的操作信息为回复1500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
-- 函数定义：设置效果②的效果处理函数
function c11851647.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
