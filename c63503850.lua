--ブルートエンフォーサー
-- 效果：
-- 效果怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：丢弃1张手卡，以对方场上1张表侧表示的卡为对象才能发动。对方可以把原本种类（怪兽·魔法·陷阱）和那张表侧表示的卡相同的1张卡从手卡丢弃让这个效果无效。没丢弃的场合，作为对象的表侧表示的卡破坏。
function c63503850.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续：需要2只效果怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- 效果怪兽2只。这个卡名的效果1回合只能使用1次。①：丢弃1张手卡，以对方场上1张表侧表示的卡为对象才能发动。对方可以把原本种类（怪兽·魔法·陷阱）和那张表侧表示的卡相同的1张卡从手卡丢弃让这个效果无效。没丢弃的场合，作为对象的表侧表示的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63503850,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,63503850)
	e1:SetCost(c63503850.descost)
	e1:SetTarget(c63503850.destg)
	e1:SetOperation(c63503850.desop)
	c:RegisterEffect(e1)
end
-- 效果①的Cost（发动代价）函数：丢弃1张手卡。
function c63503850.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的Target（发动准备/取对象）函数。
function c63503850.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的表侧表示的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张表侧表示的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的1张卡”。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：筛选手卡中原本种类与目标卡相同且可以丢弃的卡。
function c63503850.cfilter(c,typ)
	return c:IsType(typ) and c:IsDiscardable(REASON_EFFECT)
end
-- 效果①的Operation（效果处理）函数。
function c63503850.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() then return end
	-- 检查该效果是否可以被无效。
	if Duel.IsChainDisablable(0) then
		local typ=bit.band(tc:GetOriginalType(),0x7)
		local sel=1
		-- 给对方玩家发送是否丢弃原本种类相同的卡的提示信息。
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(63503850,1))  --"是否丢弃原本种类相同的卡？"
		-- 检查对方手卡中是否存在原本种类与目标卡相同的卡。
		if Duel.IsExistingMatchingCard(c63503850.cfilter,tp,0,LOCATION_HAND,1,nil,typ) then
			-- 对方手卡有对应种类的卡时，让对方选择“是”（丢弃并无效）或“否”（不丢弃）。
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 对方手卡没有对应种类的卡时，强制选择“否”（不丢弃）。
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 对方选择丢弃时，让对方从手卡丢弃1张原本种类相同的卡。
			Duel.DiscardHand(1-tp,c63503850.cfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil,typ)
			-- 使这个效果的发动无效。
			Duel.NegateEffect(0)
			return
		end
	end
	if tc:IsRelateToEffect(e) then
		-- 对方没有丢弃卡片时，将作为对象的表侧表示的卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
