--トポロジック・ガンブラー・ドラゴン
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡已在怪兽区域存在的状态，这张卡以外的怪兽在连接怪兽所连接区特殊召唤的场合发动。自己把手卡任意数量随机丢弃（最多2张）。那之后，对方选丢弃数量的手卡丢弃。
-- ②：这张卡是额外连接状态的场合才能发动。对方尽可能选最多2张手卡丢弃。这个效果让对方手卡变成0张的场合，再给与对方3000伤害。
function c22593417.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2个连接类型为效果怪兽的卡片作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：这张卡已在怪兽区域存在的状态，这张卡以外的怪兽在连接怪兽所连接区特殊召唤的场合发动。自己把手卡任意数量随机丢弃（最多2张）。那之后，对方选丢弃数量的手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22593417,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,22593417)
	e1:SetCondition(c22593417.hdcon)
	e1:SetTarget(c22593417.hdtg)
	e1:SetOperation(c22593417.hdop)
	c:RegisterEffect(e1)
	-- ②：这张卡是额外连接状态的场合才能发动。对方尽可能选最多2张手卡丢弃。这个效果让对方手卡变成0张的场合，再给与对方3000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22593417,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,22593417)
	e2:SetCondition(c22593417.hdcon2)
	e2:SetTarget(c22593417.hdtg2)
	e2:SetOperation(c22593417.hdop2)
	c:RegisterEffect(e2)
end
-- 用于判断怪兽是否在连接区域中，通过位运算提取连接区域的对应位
function c22593417.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsControler(1) then seq=seq+16 end
	return bit.extract(zone,seq)~=0
end
-- 判断是否满足效果①的发动条件，即非自身怪兽在连接区特殊召唤且满足连接区域条件
function c22593417.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方所有连接区域的位图，用于判断怪兽是否在连接区
	local zone=Duel.GetLinkedZone(0)+Duel.GetLinkedZone(1)*0x10000
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c22593417.cfilter,1,nil,zone)
end
-- 设置效果①的发动时点信息，指定自己和对方各丢弃1张手牌
function c22593417.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果①的发动时点信息，指定自己丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置效果①的发动时点信息，指定对方丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 效果①的处理函数，随机丢弃自己手牌并让对方丢弃相同数量的手牌
function c22593417.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己的手牌组
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=math.min(hg:GetCount(),2)
	if ct<=0 then return end
	local ct2=1
	-- 如果自己手牌数量大于1，则让玩家宣言丢弃1张或2张手牌
	if ct>1 then ct2=Duel.AnnounceNumber(tp,1,2) end
	local g=hg:RandomSelect(tp,ct2)
	-- 将玩家选择的随机手牌送入墓地
	local ct3=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	if ct3<=0 then return end
	-- 中断当前效果处理，使后续效果视为错时处理
	Duel.BreakEffect()
	-- 让对方丢弃与己方丢弃数量相同的手牌
	Duel.DiscardHand(1-tp,nil,ct3,ct3,REASON_EFFECT+REASON_DISCARD)
end
-- 判断该卡是否处于额外连接状态
function c22593417.hdcon2(e)
	return e:GetHandler():IsExtraLinkState()
end
-- 设置效果②的发动时点信息，指定对方丢弃2张手牌
function c22593417.hdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0，以确认效果②是否可以发动
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	-- 设置效果②的发动时点信息，指定对方丢弃2张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end
-- 效果②的处理函数，对方丢弃2张手牌，若对方手牌归零则给予对方3000伤害
function c22593417.hdop2(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方丢弃2张手牌
	if Duel.DiscardHand(1-tp,nil,2,2,REASON_EFFECT+REASON_DISCARD)~=0
		-- 判断对方丢弃后手牌数量是否为0
		and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==0 then
		-- 给予对方3000伤害
		Duel.Damage(1-tp,3000,REASON_EFFECT)
	end
end
