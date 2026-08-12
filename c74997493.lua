--鎖龍蛇－スカルデット
-- 效果：
-- 卡名不同的怪兽2只以上
-- ①：这张卡得到作为这张卡的连接素材的怪兽数量的以下效果。
-- ●2只以上：这张卡所连接区有怪兽召唤·特殊召唤的场合发动。那些怪兽的攻击力·守备力上升300。
-- ●3只以上：1回合1次，自己主要阶段才能发动。从手卡把1只怪兽特殊召唤。
-- ●4只：这张卡连接召唤时才能发动。自己抽4张。那之后，选自己3张手卡用喜欢的顺序回到卡组下面。
function c74997493.initial_effect(c)
	-- 添加连接召唤手续，需要2只以上的怪兽作为素材，且素材需满足过滤条件lcheck（卡名不同）
	aux.AddLinkProcedure(c,nil,2,nil,c74997493.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡得到作为这张卡的连接素材的怪兽数量的以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c74997493.regcon)
	e2:SetOperation(c74997493.regop)
	c:RegisterEffect(e2)
	-- ●4只：这张卡连接召唤时才能发动。自己抽4张。那之后，选自己3张手卡用喜欢的顺序回到卡组下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74997493,2))  --"抽滤"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c74997493.drcon)
	e3:SetTarget(c74997493.drtg)
	e3:SetOperation(c74997493.drop)
	c:RegisterEffect(e3)
end
-- 连接素材的过滤条件：用于连接召唤的怪兽卡名必须各不相同
function c74997493.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 检查这张卡是否是通过连接召唤特殊召唤成功的
function c74997493.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 根据连接素材的数量，赋予这张卡对应的“2只以上”和“3只以上”的效果
function c74997493.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()>=2 then
		-- ●2只以上：这张卡所连接区有怪兽召唤·特殊召唤的场合发动。那些怪兽的攻击力·守备力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(74997493,0))  --"攻击力·守备力上升"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c74997493.atkcon)
		e1:SetOperation(c74997493.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(74997493,3))  --"2只以上怪兽为素材"
	end
	if c:GetMaterialCount()>=3 then
		-- ●3只以上：1回合1次，自己主要阶段才能发动。从手卡把1只怪兽特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(74997493,1))  --"从手卡把1只怪兽特殊召唤"
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetTarget(c74997493.sptg)
		e3:SetOperation(c74997493.spop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(74997493,4))  --"3只以上怪兽为素材"
	end
end
-- 过滤条件：检查怪兽是否表侧表示存在于这张卡的连接区内
function c74997493.cfilter(c,g)
	return c:IsFaceup() and g:IsContains(c)
end
-- 触发条件：检查是否有怪兽被召唤或特殊召唤到这张卡的连接区
function c74997493.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(c74997493.cfilter,1,nil,lg)
end
-- 效果处理：使召唤或特殊召唤到连接区的怪兽攻击力和守备力上升300
function c74997493.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if not lg then return end
	local g=eg:Filter(c74997493.cfilter,nil,lg)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的攻击力·守备力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 过滤条件：检查手卡中可以被特殊召唤的怪兽
function c74997493.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 3只以上效果的发动准备：检查自身怪兽区域是否有空位，以及手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c74997493.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c74997493.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 3只以上效果的处理：让玩家从手卡选择1只怪兽表侧表示特殊召唤
function c74997493.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74997493.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 4只效果的触发条件：这张卡连接召唤成功，且使用的连接素材数量为4个
function c74997493.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetMaterialCount()==4
end
-- 4只效果的发动准备：检查玩家是否可以抽4张卡，并设置抽卡和送回卡组的操作信息
function c74997493.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以通过效果抽取4张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,4) end
	-- 将当前效果的处理对象玩家设定为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前效果的处理参数设定为4（代表抽4张卡）
	Duel.SetTargetParam(4)
	-- 设置抽卡的操作信息，表示自己将抽取4张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,4)
	-- 设置回到卡组的操作信息，表示自己将把3张手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,3)
end
-- 4只效果的处理：自己抽4张卡，之后选择3张手卡以任意顺序放回卡组最下方
function c74997493.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡处理，若成功抽取了4张卡，则继续执行后续处理
	if Duel.Draw(p,d,REASON_EFFECT)==4 then
		-- 获取自己手卡中所有可以送回卡组的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if g:GetCount()<3 then return end
		-- 洗切自己的手卡
		Duel.ShuffleHand(p)
		-- 中断当前效果处理，使后续的“放回卡组”与前面的“抽卡”不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要送回卡组的手卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,3,3,nil)
		-- 将选中的3张手卡以玩家喜欢的顺序放回卡组最下方
		aux.PlaceCardsOnDeckBottom(p,sg)
	end
end
