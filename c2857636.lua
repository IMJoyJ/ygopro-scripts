--トロイメア・フェニックス
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
-- ②：只要这张卡在怪兽区域存在，互相连接状态的自己怪兽不会被战斗破坏。
function c2857636.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求使用2只怪兽作为连接素材，且素材的卡名（由lcheck校验）各不相同。
	aux.AddLinkProcedure(c,nil,2,2,c2857636.lcheck)
	c:EnableReviveLimit()
	-- 对应效果原文：『这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤的场合，丢弃1张手卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。』
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2857636,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,2857636)
	e1:SetCondition(c2857636.descon)
	e1:SetCost(c2857636.descost)
	e1:SetTarget(c2857636.destg)
	e1:SetOperation(c2857636.desop)
	c:RegisterEffect(e1)
	-- 对应效果原文：『②：只要这张卡在怪兽区域存在，互相连接状态的自己怪兽不会被战斗破坏。』
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c2857636.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- lcheck函数：计算连接素材中不同LinkCode（连接代码）的数量，若等于素材总数则校验通过，用于确保素材是“卡名不同”的怪兽。
function c2857636.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- descon条件：这张卡是以连接召唤的方式特殊召唤成功时，效果才可发动。
function c2857636.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- descost代价：发动时丢弃1张手牌作为代价；先检查是否有可丢弃的手牌，再执行丢弃。
function c2857636.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手牌选择并丢弃1张卡（作为发动代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- destg目标处理：选择对方场上1张魔法·陷阱卡作为对象；同时根据这张卡当前是否为互相连接状态，将效果分类设为是否包含抽卡，并用标签记录状态。
function c2857636.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 目标合法性检查：确认对方场上存在满足条件的魔法·陷阱卡可以选择为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 弹出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张魔法·陷阱卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：声明将破坏该对象卡1张，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
end
-- desop效果处理：破坏对象卡；若满足发动时互相连接的状态且玩家选择抽卡，则再让玩家抽1张。
function c2857636.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且被成功破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 确认发动时卡片处于互相连接状态（标签为1）且当前玩家可以抽卡。
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否要抽卡。
		and Duel.SelectYesNo(tp,aux.Stringid(2857636,1)) then  --"是否抽卡？"
		-- 中断当前效果链，使抽卡作为独立效果处理，避免错过时点。
		Duel.BreakEffect()
		-- 让玩家抽1张卡（效果抽卡）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- indtg目标判定：作为②效果的保护对象，必须是处于互相连接状态的怪兽。
function c2857636.indtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
