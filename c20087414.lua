--久延毘古
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（天使族·地·2星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●自己场上的卡为对象的场上的怪兽的效果由对方发动时才能发动（同一连锁上最多1次）。这张卡在自己的魔法与陷阱区域盖放，那个对方的效果无效。那只怪兽的攻击力是对方场上最高的场合，再让那只怪兽回到手卡。
local s,id,o=GetID()
-- 初始化效果，创建两个效果：第一个是发动时特殊召唤自身为效果怪兽，第二个是连锁时点发动的效果
function s.initial_effect(c)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（天使族·地·2星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●自己场上的卡为对象的场上的怪兽的效果由对方发动时才能发动（同一连锁上最多1次）。这张卡在自己的魔法与陷阱区域盖放，那个对方的效果无效。那只怪兽的攻击力是对方场上最高的场合，再让那只怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤的条件，包括是否有足够的怪兽区域和是否可以特殊召唤该怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 判断玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤该怪兽（以效果怪兽陷阱卡形式）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_FAIRY,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果时执行的操作，将该卡以效果怪兽陷阱卡形式特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤该怪兽（以效果怪兽陷阱卡形式）
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_FAIRY,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将该卡特殊召唤到场上，作为效果怪兽陷阱卡
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 过滤函数，用于判断目标卡是否为玩家控制且在场上
function s.discfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
-- 判断是否满足无效连锁效果的条件，包括是否为对方发动的怪兽效果、是否为目标为己方场上的怪兽、是否可以无效该连锁
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF then return false end
	if rp~=1-tp or not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的触发位置和目标卡组
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	-- 返回是否满足连锁无效条件，包括触发位置为怪兽区域、目标卡组存在且包含己方场上卡、该连锁可以被无效
	return loc==LOCATION_MZONE and tg and tg:IsExists(s.discfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 设置无效连锁效果的目标信息，包括使效果无效和将目标怪兽送回手牌
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	local rchk=tg:IsContains(rc) and rc:IsRelateToEffect(re)
	if chk==0 then return c:IsSSetable() and (not rchk or rc:IsAbleToHand()) end
	-- 设置操作信息，表示将要使目标效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if rchk then
		-- 设置操作信息，表示将要将目标怪兽送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
	end
end
-- 执行无效连锁效果的操作，包括盖放自身、使效果无效、将目标怪兽送回手牌
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判断是否满足执行无效连锁效果的条件，包括自身是否在场、是否可以盖放、是否可以无效该连锁、目标怪兽是否为对方场上攻击力最高者
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c) and Duel.NegateEffect(ev) and tg:IsContains(rc) and rc:IsRelateToEffect(re) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(rc,nil,REASON_EFFECT)
	end
end
