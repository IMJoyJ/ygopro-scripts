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
-- 该函数用于处理卡的发动时的区域选择操作
function c14839621.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算当前玩家和对手场上可用的怪兽区域总数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
	-- 检查是否可以使用对方的额外怪兽区（位置5）和我方的额外怪兽区（位置6）
	if Duel.CheckLocation(tp,LOCATION_MZONE,5) and Duel.CheckLocation(1-tp,LOCATION_MZONE,6) then ft=ft+1 end
	-- 检查是否可以使用我方的额外怪兽区（位置5）和对方的额外怪兽区（位置6）
	if Duel.CheckLocation(tp,LOCATION_MZONE,6) and Duel.CheckLocation(1-tp,LOCATION_MZONE,5) then ft=ft+1 end
	if chk==0 then return ft>0 end
	-- 让玩家选择一个可用的怪兽区域
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0)
	e:SetLabel(seq)
	-- 向玩家提示所选择的区域
	Duel.Hint(HINT_ZONE,tp,seq)
end
-- 该函数用于过滤满足条件的怪兽，判断其是否在指定区域
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
-- 该函数用于判断是否满足效果发动条件
function c14839621.thcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetLabelObject():GetLabel()
	return eg:IsExists(c14839621.cfilter,1,nil,seq,tp)
end
-- 该函数用于设置效果发动时的目标和操作信息
function c14839621.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetLabelObject():GetLabel()
	local g=eg:Filter(c14839621.cfilter,nil,seq,tp)
	local tg=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 设置当前效果的目标卡片组
	Duel.SetTargetCard(tg)
	g:AddCard(e:GetHandler())
	-- 设置当前效果操作信息，指定将卡片送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 该函数用于执行效果的处理操作
function c14839621.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中目标卡片组，并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	g:AddCard(c)
	if g:GetCount()==2 then
		-- 将符合条件的卡片送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
