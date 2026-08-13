--試号閃刀姫－アマツ
-- 效果：
-- 「闪刀姬」怪兽1只
-- 自己对「试号闪刀姬-天津」1回合只能有1次特殊召唤，那些①②的效果1回合各能使用1次。
-- ①：对方场上的攻击力2000以上的怪兽把效果发动时才能发动。那个效果变成「对方场上1只「闪刀姬」连接怪兽破坏」。
-- ②：这张卡和对方怪兽进行战斗的攻击宣言时，以自己场上1只「闪刀姬」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 这段代码为「试号闪刀姬-天津」完成初始化：设置同名卡1回合1次特殊召唤限制、连接素材条件与苏生限制，并注册①的效果变更（快速效果）和②的战斗破坏（诱发效果）两个效果。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 为这张卡添加连接召唤手续：使用1只满足s.matfilter条件的怪兽作为连接素材进行连接召唤。
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
-- 连接素材过滤条件：该怪兽作为连接素材时视为名字带有「闪刀姬」字段，可满足「『闪刀姬』怪兽1只」的素材要求。
function s.matfilter(c)
	return c:IsLinkSetCard(0x1115)
end
-- ①的发动条件：当前连锁的效果由对方玩家发动，且发动位置在场上，发动效果的是攻击力2000以上的怪兽效果。
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁序号ev中取出该效果的发动玩家、发动位置和发动怪兽的攻击力。
	local p,loc,atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTACK)
	return p==1-tp and (LOCATION_ONFIELD&loc)~=0 and re:IsActiveType(TYPE_MONSTER) and atk>=2000
end
-- 用于选择「对方场上1只『闪刀姬』连接怪兽」的过滤条件：表侧表示、字段为「闪刀姬」且为连接怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1115) and c:IsType(TYPE_LINK)
end
-- ①的效果发动合法性判定：在效果发动时检查是否存在1只对方场上的「闪刀姬」连接怪兽，使之后的效果变更能够处理。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动合法性检查）时：确认对方场上存在至少1只满足s.desfilter的「闪刀姬」连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,rp,0,LOCATION_MZONE,1,nil) end
end
-- ①的效果处理：清空当前连锁的取对象信息，并将该连锁的效果处理函数替换为s.repop，使原效果变成「破坏对方场上1只『闪刀姬』连接怪兽」。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将当前连锁ev的被取对象卡片组替换为空组，即取消原效果可能存在的对象。
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁ev的处理函数改为s.repop，之后按s.repop执行破坏效果。
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 被变更后的效果处理：从对方场上选择1只「闪刀姬」连接怪兽并破坏，若不选择则不破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示当前玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上（含额外怪兽区）选择1只满足s.desfilter的表侧「闪刀姬」连接怪兽。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 为选中的卡播放被选择为对象的动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选中的「闪刀姬」连接怪兽以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②的发动条件：这张卡与对方控制的怪兽进行战斗的攻击宣言时，可以发动效果。这里取得这张卡的战斗对象并保存，确认该战斗对象存在且由对方控制。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	e:SetLabelObject(ac)
	return ac and ac:IsControler(1-tp)
end
-- 用于选择「自己场上1只『闪刀姬』怪兽」的过滤条件：表侧表示且字段为「闪刀姬」；不要求连接怪兽。
function s.desfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x1115)
end
-- ②的取对象目标处理：需要同时选择自己场上1只「闪刀姬」怪兽和对方场上1张卡作为对象；先验证可选择的卡存在，再选择并设置破坏信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 合法性检查：确认自己场上存在1只表侧表示且字段为「闪刀姬」的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 合法性检查：同时确认对方场上存在至少1张卡（任意卡）可以作为对象。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示当前玩家选择要破坏的自己场上的「闪刀姬」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以取对象方式从自己场上选择1只满足s.desfilter2的「闪刀姬」怪兽。
	local g1=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示选择提示，提示当前玩家选择要破坏的对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以取对象方式从对方场上选择1张卡（任意卡）作为破坏对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置破坏的操作信息：将选中的两张对象卡作为可能被破坏的卡，数量为2，效果分类为破坏，供相关卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②的效果处理：取回合开始时选择的对象卡组，筛掉已不连锁的卡，将其全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②发动时选择的对象卡组（自己场上1只「闪刀姬」怪兽和对方场上1张卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToChain,nil)
	if tg:GetCount()>0 then
		-- 将仍与效果相关的对象卡以效果原因破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
