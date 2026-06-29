--久延毘古
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（天使族·地·2星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●自己场上的卡为对象的场上的怪兽的效果由对方发动时才能发动（同一连锁上最多1次）。这张卡在自己的魔法与陷阱区域盖放，那个对方的效果无效。那只怪兽的攻击力是对方场上最高的场合，再让那只怪兽回到手卡。
local s,id,o=GetID()
-- 注册陷阱卡发动并特召自身为怪兽的效果、以及无效对方怪兽效果并返回手卡盖放的效果
function s.initial_effect(c)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（天使族·地·2星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●自己场上的卡为对象的场上的怪兽的效果由对方发动时才能发动（同一连锁上最多1次）。这张卡在自己的魔法与陷阱区域盖放，那个对方的效果无效。那只怪兽的攻击力是对方场上最高的场合，再让那只怪兽回到持有者手卡。
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
-- 陷阱卡发动并特召自身效果的发动准备
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有空闲怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认系统是否允许将此卡作为陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_FAIRY,ATTRIBUTE_EARTH) end
	-- 设置操作信息为将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 陷阱卡发动并特召自身效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己场上已无空怪兽区域或由于限制无法特召，则效果不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_FAIRY,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 为该卡片添加陷阱怪兽属性并特殊召唤到自己场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断被选择的对象是否是自己场上的卡片
function s.discfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
-- 无效对方怪兽效果并盖放效果的触发条件判断
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or c:GetSummonType()~=SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF then return false end
	if rp~=1-tp or not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取链信息并判断对方效果是否在主要怪兽区域触发，且是否以自己场上的卡为对象
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	-- 确保当前连锁中的对方效果是可被无效的
	return loc==LOCATION_MZONE and tg and tg:IsExists(s.discfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 无效对方怪兽效果并盖放效果的发动准备
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 获取对方场上表侧表示怪兽中攻击力最高的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	local rchk=tg:IsContains(rc) and rc:IsRelateToEffect(re)
	if chk==0 then return c:IsSSetable() and (not rchk or rc:IsAbleToHand()) end
	-- 设置操作信息为无效该怪兽效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if rchk then
		-- 若对方发动的怪兽攻击力是对方场上最高，则设置操作信息为将其返回手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
	end
end
-- 无效对方怪兽效果并盖放效果的执行
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上表侧表示怪兽中攻击力最高的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 若此卡与效果关联，则将此卡在魔陷区域盖放，并使对方的怪兽效果无效
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 and Duel.NegateEffect(ev) and tg:IsContains(rc) and rc:IsRelateToEffect(re) then
		-- 切断效果处理的连锁时点
		Duel.BreakEffect()
		-- 若被无效的怪兽攻击力是对方场上最高且与链关联，则将其送回持有者手卡
		Duel.SendtoHand(rc,nil,REASON_EFFECT)
	end
end
