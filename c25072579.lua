--試号閃刀姫－アマツ
-- 效果：
-- 「闪刀姬」怪兽1只
-- 自己对「试号闪刀姬-天津」1回合只能有1次特殊召唤，那些①②的效果1回合各能使用1次。
-- ①：对方场上的攻击力2000以上的怪兽把效果发动时才能发动。那个效果变成「对方场上1只「闪刀姬」连接怪兽破坏」。
-- ②：这张卡和对方怪兽进行战斗的攻击宣言时，以自己场上1只「闪刀姬」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片的特殊召唤限制、连接召唤手续、效果注册
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 添加连接召唤手续，要求使用1只满足过滤条件的连接素材
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	-- ①：对方场上的攻击力2000以上的怪兽把效果发动时才能发动。那个效果变成「对方场上1只「闪刀姬」连接怪兽破坏」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果变更"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的攻击宣言时，以自己场上1只「闪刀姬」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数，筛选出「闪刀姬」系列的连接怪兽
function s.matfilter(c)
	return c:IsLinkSetCard(0x1115)
end
-- 连锁发动条件判断函数，判断是否为对方场上攻击力2000以上的怪兽发动的效果
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动玩家、位置和攻击力信息
	local p,loc,atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTACK)
	return p==1-tp and (LOCATION_ONFIELD&loc)~=0 and re:IsActiveType(TYPE_MONSTER) and atk>=2000
end
-- 效果变更时用于筛选对方场上的「闪刀姬」连接怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1115) and c:IsType(TYPE_LINK)
end
-- 效果变更的发动时点处理函数，判断是否满足发动条件
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即对方场上是否存在至少1只「闪刀姬」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,rp,0,LOCATION_MZONE,1,nil) end
end
-- 效果变更的处理函数，将连锁对象清空并替换为新的处理函数
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将当前连锁的对象卡组设置为空组
	Duel.ChangeTargetCard(ev,g)
	-- 将当前连锁的处理函数替换为s.repop函数
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 效果变更的处理函数，选择并破坏对方场上的「闪刀姬」连接怪兽
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只「闪刀姬」连接怪兽
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 攻击宣言时的触发条件判断函数，判断是否与对方怪兽战斗
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	e:SetLabelObject(ac)
	return ac and ac:IsControler(1-tp)
end
-- 攻击破坏效果中用于筛选自己场上的「闪刀姬」怪兽
function s.desfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x1115)
end
-- 攻击破坏效果的发动时点处理函数，判断是否满足发动条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件，即自己场上是否存在至少1只「闪刀姬」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 判断是否满足发动条件，即对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1只「闪刀姬」怪兽
	local g1=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，指定要破坏的卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 攻击破坏效果的处理函数，破坏选中的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToChain,nil)
	if tg:GetCount()>0 then
		-- 将选中的卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
