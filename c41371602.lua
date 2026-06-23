--スタンドアップ・センチュリオン！
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有「百夫长骑士」怪兽卡存在，这张卡不会被对方的效果破坏。
-- ②：这张卡发动的回合的自己主要阶段，把1张手卡送去墓地才能发动。从卡组把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：怪兽特殊召唤的场合才能发动。用包含「百夫长骑士」怪兽的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 注册卡的效果，包括①②③效果
function s.initial_effect(c)
	-- ①：只要自己场上有「百夫长骑士」怪兽卡存在，这张卡不会被对方的效果破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(s.reg)
	c:RegisterEffect(e0)
	-- ②：这张卡发动的回合的自己主要阶段，把1张手卡送去墓地才能发动。从卡组把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.con)
	-- 设置效果值为aux.indoval，表示不会被对方效果破坏
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ③：怪兽特殊召唤的场合才能发动。用包含「百夫长骑士」怪兽的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 同调召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.sccon)
	e3:SetTarget(s.sctg)
	e3:SetOperation(s.scop)
	c:RegisterEffect(e3)
end
-- 注册flag，用于标记该卡是否已发动过②③效果
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤函数，用于判断场上是否存在「百夫长骑士」怪兽
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a2) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断场上是否存在「百夫长骑士」怪兽
function s.con(e)
	local tp=e:GetHandlerPlayer()
	-- 判断场上是否存在「百夫长骑士」怪兽
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否为发动的回合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 丢弃一张手卡作为代价
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以丢弃一张手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤函数，用于筛选「百夫长骑士」怪兽
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置②效果的发动条件
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以发动②效果
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上是否有足够的魔法与陷阱区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 执行②效果，将「百夫长骑士」怪兽当作永续陷阱卡使用
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有足够的魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的「百夫长骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽移动到魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽转换为永续陷阱卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断怪兽是否为表侧表示
function s.scconfilter(c,tp)
	return c:IsFaceup()
end
-- 判断是否有怪兽被特殊召唤成功
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.scconfilter,1,nil,tp)
end
-- 过滤函数，用于筛选「百夫长骑士」怪兽
function s.mfilter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 校验同调素材是否满足条件
function s.syncheck(g,tp,syncard)
	-- 校验同调素材是否满足条件
	return g:IsExists(s.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 筛选可以进行同调召唤的怪兽
function s.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调等级检查函数
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	-- 清除同调等级检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 设置③效果的发动条件
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否可以特殊召唤
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家的同调素材
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手卡中的同调素材
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查是否有满足条件的同调怪兽
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 提示对方玩家选择了同调召唤
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，用于处理同调召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行③效果，进行同调召唤
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的同调素材
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手卡中的同调素材
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 筛选可以进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,s.syncheck,false,2,#mg,tp,sc)
		-- 执行同调召唤
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
