--トロイメア・フェニックス
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
-- ②：只要这张卡在怪兽区域存在，互相连接状态的自己怪兽不会被战斗破坏。
function c2857636.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2个连接素材且素材怪兽卡名不能相同
	aux.AddLinkProcedure(c,nil,2,2,c2857636.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，丢弃1张手卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
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
	-- ②：只要这张卡在怪兽区域存在，互相连接状态的自己怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c2857636.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 连接素材怪兽卡名不能相同的过滤条件函数
function c2857636.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果发动条件：这张卡是连接召唤成功
function c2857636.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动费用：丢弃1张手卡
function c2857636.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时选择对象：选择对方场上1张魔法·陷阱卡
function c2857636.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
end
-- 效果处理：破坏选择的魔法·陷阱卡，若满足条件则抽一张卡
function c2857636.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍然在场上且能被破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断是否满足抽卡条件：互相连接状态且可以抽卡
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(2857636,1)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 执行抽卡操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断是否为互相连接状态的自己怪兽
function c2857636.indtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
