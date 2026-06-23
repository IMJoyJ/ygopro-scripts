--星読みの魔術師－ホロスコープ・マジシャン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：对方发动的魔法卡的效果的处理时，自己场上有「魔术师」灵摆怪兽或「异色眼」怪兽存在的场合，可以把那个发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②③的怪兽效果1回合各能使用1次。
-- ①：从手卡丢弃1只其他的「魔术师」灵摆怪兽、「娱乐伙伴」怪兽、「异色眼」怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1只攻击力2500的灵摆怪兽加入手卡。
-- ③：以自己场上1张灵摆怪兽卡为对象才能发动。那张卡破坏。那之后，可以从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的入口函数
function s.initial_effect(c)
	-- 开启灵摆怪兽的灵摆属性与灵摆召唤/发动机制
	aux.EnablePendulumAttribute(c)
	-- ①：对方发动的魔法卡的效果的处理时，自己场上有「魔术师」灵摆怪兽或「异色眼」怪兽存在的场合，可以把那个发动的效果无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ①：从手卡丢弃1只其他的「魔术师」灵摆怪兽、「娱乐伙伴」怪兽、「异色眼」怪兽才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把1只攻击力2500的灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：以自己场上1张灵摆怪兽卡为对象才能发动。那张卡破坏。那之后，可以从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的「异色眼」怪兽或表侧表示的「魔术师」灵摆怪兽
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x99)
		or c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM))
end
-- 发动条件：对方发动的魔法卡效果处理时，且自己本回合未发动过此效果，场上存在符合条件的怪兽，且效果可被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查效果是否由对方玩家发动，且自己本回合未使用过该灵摆效果
	return rp==1-tp and Duel.GetFlagEffect(tp,id)==0
		and re:IsActiveType(TYPE_SPELL)
		-- 检查自己场上是否存在「魔术师」灵摆怪兽或「异色眼」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前连锁的效果是否可以被无效，且当前未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 效果处理：询问玩家是否将对方发动的魔法卡效果无效，若无效则将这张卡（自身）破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确保自己本回合尚未使用过该灵摆效果
	if Duel.GetFlagEffect(tp,id)==0
		-- 让玩家选择是否适用此效果将对方的效果无效
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,4)) then  --"是否适用「星读之魔术师-星占之魔术士」的效果来无效？"
		-- 在场上展示卡片发动动画以示效果适用
		Duel.Hint(HINT_CARD,0,id)
		-- 为玩家注册本回合已使用过该效果的标记，持续到回合结束
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 如果成功使对方发动的效果无效
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，使之后的效果处理与无效效果不同时发生
			Duel.BreakEffect()
			-- 将自己灵摆区域的这张卡破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 过滤条件：手卡中其他的「娱乐伙伴」怪兽、「异色眼」怪兽或「魔术师」灵摆怪兽，且可以作为代价丢弃
function s.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x99,0x9f)
		or c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)) and c:IsDiscardable()
end
-- 发动代价：从手卡丢弃1只其他的符合条件的怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡中除这张卡外是否存在可作为发动代价丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家从手卡选择1只符合条件的怪兽丢弃
	Duel.DiscardHand(tp,s.cfilter2,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果靶向：确认有可用怪兽区域，且自身可被特殊召唤，并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将手卡中的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中攻击力2500的灵摆怪兽且可以加入手牌
function s.thfilter(c)
	return c:IsAttack(2500) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果靶向：确认卡组存在符合检索条件的卡，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合条件的攻击力2500的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只攻击力2500的灵摆怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只符合条件的攻击力2500的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示原本是怪兽且是灵摆怪兽的卡
function s.desfilter(c)
	return c:IsFaceup() and (c:GetOriginalType()&(TYPE_PENDULUM|TYPE_MONSTER)==TYPE_PENDULUM|TYPE_MONSTER)
end
-- 过滤条件：额外卡组表侧表示的灵摆怪兽且可以加入手牌
function s.thfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果靶向：选择自己场上1张符合条件的灵摆怪兽卡作为对象，设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.desfilter(chkc) and chkc:IsControler(tp) and chkc:IsOnField() end
	-- 判断自己场上是否存在符合条件的可作为对象的灵摆怪兽卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张原本为怪兽的灵摆卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：破坏选中的对象卡（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将选中的对象卡破坏，之后可选择将额外卡组（表侧）的1只灵摆怪兽加入手卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否依然存在并成功将其破坏
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断自己额外卡组（表侧表示）是否存在符合条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_EXTRA,0,1,nil)
		-- 询问玩家是否选择将额外卡组表侧表示的1只灵摆怪兽加入手卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从额外卡组（表侧表示）选择1只灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使破坏与检索不视为同时发生
			Duel.BreakEffect()
			-- 将选中的额外卡组表侧怪兽送入玩家手卡
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 给对方确认从额外卡组加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
