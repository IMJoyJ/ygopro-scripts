--ドカンポリン
-- 效果：
-- 指定没有使用的怪兽区域1处才能把这张卡发动。
-- ①：指定的区域有效果怪兽特殊召唤的场合发动。那个区域存在的怪兽和这张卡共2张回到持有者手卡。
function c14839621.initial_effect(c)
	-- 指定没有使用的怪兽区域1处才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14839621.target)
	c:RegisterEffect(e1)
	-- ①：指定的区域有效果怪兽特殊召唤的场合发动。那个区域存在的怪兽和这张卡共2张回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14839621,0))  --"2张卡回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c14839621.thcon)
	e2:SetTarget(c14839621.thtg)
	e2:SetOperation(c14839621.thop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 发动时的处理：计算双方场上可用怪兽区域总数；若存在空位，则让玩家从双方所有未使用的怪兽区域中选择1处（包括主要怪兽区和额外怪兽区），并将所选区域的位置标记保存在效果e的Label中，随后向双方展示所选区域。
function c14839621.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方场上可用的主要怪兽区域空格数之和，用于判断是否仍有可发动选择区域。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
	-- 若自己场上的额外怪兽区(序号5)与对方场上的额外怪兽区(序号6)同时为空，则可选额外怪兽区域数量增加1。
	if Duel.CheckLocation(tp,LOCATION_MZONE,5) and Duel.CheckLocation(1-tp,LOCATION_MZONE,6) then ft=ft+1 end
	-- 若自己场上的额外怪兽区(序号6)与对方场上的额外怪兽区(序号5)同时为空，则可选额外怪兽区域数量再增加1。
	if Duel.CheckLocation(tp,LOCATION_MZONE,6) and Duel.CheckLocation(1-tp,LOCATION_MZONE,5) then ft=ft+1 end
	if chk==0 then return ft>0 end
	-- 让发动者从双方场上所有未使用的怪兽区域中选择1处，返回该位置的位标记（bitmask），用于记录指定区域。
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0)
	e:SetLabel(seq)
	-- 向双方玩家发送ZONE类型提示，展示被选择的怪兽区域的位置。
	Duel.Hint(HINT_ZONE,tp,seq)
end
-- 筛选函数：判断一只怪兽是否被特殊召唤到了指定的区域seq。若怪兽仍在场上，则要求其为表侧表示的效果怪兽且其所在格子的位标记与seq对应；若已离场，则根据其特殊召唤前的位置、控制者和在场上的类型判断，要求原位置与seq对应且原在场类型为效果怪兽。
function c14839621.cfilter(c,seq,tp)
	local nseq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1-tp) then nseq=nseq+16 end
		return c:IsFaceup() and c:IsType(TYPE_EFFECT) and bit.extract(seq,nseq)~=0
	else
		nseq=c:GetPreviousSequence()
		if c:IsPreviousControler(1-tp) then nseq=nseq+16 end
		return bit.band(c:GetPreviousTypeOnField(),TYPE_EFFECT)~=0 and bit.extract(seq,nseq)~=0
	end
end
-- 诱发条件：当有怪兽被特殊召唤到发动时选择的区域时，本效果自动发动（必发）；通过检查eg中是否存在满足cfilter的怪兽来判断。
function c14839621.thcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetLabelObject():GetLabel()
	return eg:IsExists(c14839621.cfilter,1,nil,seq,tp)
end
-- 效果发动时的处理：从本次特殊召唤成功的怪兽中筛选出位于所选区域的怪兽，将其中仍处于怪兽区的怪兽登记为连锁对象（建立关联），再把自己这张卡也加入处理组，并设置操作信息为将这些卡返回手牌。
function c14839621.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetLabelObject():GetLabel()
	local g=eg:Filter(c14839621.cfilter,nil,seq,tp)
	local tg=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 将筛选出的位于指定区域且仍在场上的怪兽登记为当前连锁的目标卡，使这些卡与本次效果建立关联，用于处理时判断是否仍有效。
	Duel.SetTargetCard(tg)
	g:AddCard(e:GetHandler())
	-- 设置操作信息：本连锁的效果包含返回手牌分类，预计处理的卡为g（含这张卡自身），数量为g的卡数；供其他卡/效果进行连锁响应时查询。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：从连锁信息中取出之前登记的目标卡，过滤出仍与本次效果有关联的怪兽；再把这张卡自身加入其中。若合计数量为2，则将它们返回持有者手卡；若因卡已离场等原因不为2，则不处理。
function c14839621.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中获取之前登记的目标卡组，并筛选出仍然与效果e有关联的卡（即未因离场等原因解除关联）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	g:AddCard(c)
	if g:GetCount()==2 then
		-- 以效果原因将g中的所有卡返回各自持有者的手卡（这里包括原特召怪兽和这张魔法卡自身）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
