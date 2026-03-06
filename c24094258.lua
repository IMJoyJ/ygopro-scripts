--ヘビーメタルフォーゼ・エレクトラム
-- 效果：
-- 灵摆怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只灵摆怪兽表侧加入额外卡组。
-- ②：1回合1次，以自己场上1张其他的表侧表示卡为对象才能发动。那张卡破坏。那之后，从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
-- ③：自己的灵摆区域的卡从场上离开的场合发动。自己抽1张。
function c24094258.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2个满足灵摆类型的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2)
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1只灵摆怪兽表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24094258,0))  --"卡组灵摆怪兽加入额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c24094258.tecon)
	e1:SetTarget(c24094258.tetg)
	e1:SetOperation(c24094258.teop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1张其他的表侧表示卡为对象才能发动。那张卡破坏。那之后，从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24094258,1))  --"破坏并从额外卡组把灵摆怪兽加入手卡"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c24094258.destg)
	e2:SetOperation(c24094258.desop)
	c:RegisterEffect(e2)
	-- ③：自己的灵摆区域的卡从场上离开的场合发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24094258,2))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,24094258)
	e3:SetCondition(c24094258.drcon)
	e3:SetTarget(c24094258.drtg)
	e3:SetOperation(c24094258.drop)
	c:RegisterEffect(e3)
end
-- 效果条件：判断此卡是否为连接召唤
function c24094258.tecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：判断卡片是否为灵摆类型
function c24094258.tefilter(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 效果目标：检查玩家卡组是否存在灵摆怪兽
function c24094258.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否存在至少1张灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24094258.tefilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：指定将1张卡从卡组加入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家选择1张灵摆怪兽加入额外卡组
function c24094258.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入额外卡组的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(24094258,3))  --"请选择要表侧表示加入额外卡组的卡"
	-- 选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c24094258.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入额外卡组
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数：判断卡片是否为灵摆类型且可加入手牌
function c24094258.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果目标：检查场上是否存在可破坏的表侧表示卡及额外卡组是否存在灵摆怪兽
function c24094258.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=c end
	-- 检查场上是否存在至少1张表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,c)
		-- 检查额外卡组是否存在至少1张灵摆怪兽
		and Duel.IsExistingMatchingCard(c24094258.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的卡
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置操作信息：指定将1张卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：指定将1张卡从额外卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：破坏选中的卡并从额外卡组加入手牌
function c24094258.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c24094258.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的灵摆怪兽加入手牌
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 确认对手查看加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤函数：判断卡片是否从灵摆区域离开且为当前玩家控制
function c24094258.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp)
end
-- 效果条件：判断是否有灵摆区域的卡离开
function c24094258.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24094258.drcfilter,1,nil,tp)
end
-- 效果目标：设置抽卡效果
function c24094258.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置操作信息：指定抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡效果
function c24094258.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
