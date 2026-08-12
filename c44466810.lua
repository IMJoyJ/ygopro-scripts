--ロード・オブ・ザ・タキオンギャラクシー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己·对方的战斗阶段，把自己场上的「银河眼」超量怪兽1个超量素材取除才能发动（自己场上有「混沌No.」怪兽存在的场合，这张卡的发动和效果不会被无效化）。让这个回合召唤·特殊召唤的对方场上的怪兽全部回到卡组。
local s,id,o=GetID()
-- 注册主效果，使该卡可以在自由连锁时发动，条件为战斗阶段且自身场上有银河眼超量怪兽，消耗为取除1个超量素材，效果为让对方召唤或特殊召唤的怪兽回到卡组
function s.initial_effect(c)
	-- ①：自己·对方的战斗阶段，把自己场上的「银河眼」超量怪兽1个超量素材取除才能发动（自己场上有「混沌No.」怪兽存在的场合，这张卡的发动和效果不会被无效化）。让这个回合召唤·特殊召唤的对方场上的怪兽全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"全部回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.tdcon)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- 自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「时空银河支配者」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 创建用于记录召唤和特殊召唤的全局效果，用于标记回合内召唤或特殊召唤的怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 将记录召唤成功的全局效果注册到场上
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将记录特殊召唤成功的全局效果注册到场上
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当有怪兽召唤成功时，为这些怪兽设置一个标记，用于识别是否为本回合召唤或特殊召唤的怪兽
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历所有召唤成功的怪兽，为它们设置标记
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤函数，用于判断是否为场上的银河眼怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x307b)
end
-- 判断手牌发动条件，检查自己场上是否存在银河眼怪兽
function s.handcon(e)
	-- 检查自己场上是否存在银河眼怪兽
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判断发动条件，检查当前是否处于战斗阶段
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤函数，用于筛选场上的银河眼超量怪兽
function s.xfilter(c)
	return c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 计算发动消耗，从场上的银河眼超量怪兽中获取超量素材并送入墓地
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xg=Group.CreateGroup()
	-- 获取场上的银河眼超量怪兽
	local mg=Duel.GetMatchingGroup(s.xfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历场上的银河眼超量怪兽，获取其超量素材
	for tc in aux.Next(mg) do
		xg:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return xg:GetCount()>0 end
	local cost=xg:Select(tp,1,1,nil)
	-- 将选中的超量素材送入墓地作为发动代价
	Duel.SendtoGrave(cost,REASON_COST)
end
-- 过滤函数，用于筛选本回合召唤或特殊召唤的对方怪兽
function s.tdfilter(c)
	return c:GetFlagEffect(id)>0 and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤函数，用于判断是否为场上的混沌No.怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1048) and c:IsFaceup()
end
-- 设置发动时的处理信息，确定要送回卡组的怪兽数量，并在存在混沌No.怪兽时设置效果不可无效
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的对方怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取所有满足条件的对方怪兽
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定要送回卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_MZONE)
	-- 检查是否存在混沌No.怪兽，若存在则设置效果不可无效
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		e:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	end
end
-- 执行效果，将满足条件的对方怪兽送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的对方怪兽
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_MZONE,nil)
	-- 将怪兽送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
