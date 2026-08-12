--久延毘古
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（天使族·地·2星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●自己场上的卡为对象的场上的怪兽的效果由对方发动时才能发动（同一连锁上最多1次）。这张卡在自己的魔法与陷阱区域盖放，那个对方的效果无效。那只怪兽的攻击力是对方场上最高的场合，再让那只怪兽回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册e1作为陷阱卡的发动效果（特殊召唤类，1回合只能发动1张），以及e2作为怪兽区域的诱发即时效果（对方发动以我方场上的卡为对象的怪兽效果时，将其无效并可能回手）
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡发动后变成持有以下效果的效果怪兽（天使族·地·2星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
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
-- 发动条件检查：确认已支付代价、我方怪兽区域有空位、且可以特殊召唤这张陷阱怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查我方主要怪兽区域是否有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤这张作为效果怪兽的陷阱怪兽（天使族·地·2星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_FAIRY,ATTRIBUTE_EARTH) end
	-- 设置操作信息：本次连锁确定要特殊召唤这张卡自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：再次确认可以特殊召唤后，为这张卡添加效果怪兽属性（仍当作陷阱卡使用），并将其特殊召唤到自己场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时若已不能特殊召唤该陷阱怪兽则中断处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_FAIRY,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以自身效果特殊召唤到自己场上（表侧表示）
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 过滤函数：筛选控制者为tp且在场上存在的卡（即我方场上的卡）
function s.discfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
-- 发动条件：这张卡不是战斗破坏确定状态且是自身效果特殊召唤的；由对方发动的取对象的怪兽效果；且该效果从怪兽区域发动、对象包含我方场上的卡、该连锁可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or c:GetSummonType()~=SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF then return false end
	if rp~=1-tp or not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的发动位置和对象卡片组
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	-- 确认该效果从怪兽区域发动、其对象中存在我方场上的卡、且该连锁的效果可以被无效
	return loc==LOCATION_MZONE and tg and tg:IsExists(s.discfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 对象选择/目标检查：获取对方场上表侧表示怪兽中攻击力最高的怪兽群，判断发动效果的怪兽是否在其中；检查这张卡可以盖放（且若需回手则那只怪兽可以回到手卡），并设置无效（及回手）的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 检索对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	local rchk=tg:IsContains(rc) and rc:IsRelateToEffect(re)
	if chk==0 then return c:IsSSetable() and (not rchk or rc:IsAbleToHand()) end
	-- 设置操作信息：确定要将该连锁的对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if rchk then
		-- 若发动效果的怪兽攻击力为对方场上最高，设置将其回到手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
	end
end
-- 效果处理：重新取得对方场上攻击力最高的怪兽群；这张卡盖放到我方魔法与陷阱区域、使对方那个效果无效，且若那只怪兽攻击力为对方场上最高，则再让那只怪兽回到手卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判断这张卡与效果关联并成功盖放、成功无效对方效果，且发动效果的怪兽在对方场上攻击力最高怪兽群中并与效果关联
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 and Duel.NegateEffect(ev) and tg:IsContains(rc) and rc:IsRelateToEffect(re) then
		-- 中断当前效果处理，使之后的回手处理与无效处理视为不同时进行
		Duel.BreakEffect()
		-- 将那只发动效果的怪兽以效果原因送回持有者手卡
		Duel.SendtoHand(rc,nil,REASON_EFFECT)
	end
end
