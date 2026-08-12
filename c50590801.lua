--エルフェンノーツ～託選のアリスティア～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次，①②的效果在同一连锁上不能发动。
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
-- ②：自己场上有「耀圣」怪兽3只以上存在，对方把魔法·陷阱卡发动时才能发动。那个效果无效。自己场上有同调怪兽存在的场合，可以再把那张无效的卡破坏。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使该卡可以被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"移动位置"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「耀圣」怪兽3只以上存在，对方把魔法·陷阱卡发动时才能发动。那个效果无效。自己场上有同调怪兽存在的场合，可以再把那张无效的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 判断是否满足①效果的发动条件，包括场上存在1只表侧表示怪兽、有可用的怪兽区域、且该玩家未在本回合使用过②效果
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的己方怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 检查己方是否有足够的怪兽区域用于移动怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 检查该玩家是否已在本回合使用过②效果（通过标识效果判断）
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 注册一个标识效果，防止该玩家在本回合再次发动②效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 提示玩家选择要移动的怪兽对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽并设置为当前连锁的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理①效果的发动操作，获取目标怪兽并判断是否满足移动条件
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsLocation(LOCATION_MZONE) or tc:IsControler(1-tp)
		-- 检查目标怪兽是否仍然在场、是否属于己方、是否有可用的怪兽区域进行移动
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要将怪兽移动到的目标区域
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个可用的怪兽区域位置
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(seq,2)
	-- 将目标怪兽移动到指定区域
	Duel.MoveSequence(tc,nseq)
end
-- 定义过滤函数，用于判断是否为表侧表示的「耀圣」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d8)
end
-- 判断②效果是否可以发动，包括对方发动魔法/陷阱卡、该连锁可被无效、己方场上有3只以上「耀圣」怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方是否发动了魔法或陷阱卡（即该连锁为魔法/陷阱卡发动）
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查己方场上有至少3只表侧表示的「耀圣」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 设置②效果的目标处理信息，包括使效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的发动条件，即该玩家未在本回合使用过②效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册一个标识效果，防止该玩家在本回合再次发动②效果
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 设置操作信息，表示将使对方发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义过滤函数，用于判断是否为表侧表示的同调怪兽
function s.cdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 处理②效果的发动操作，包括使效果无效并可能破坏该卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 尝试使对方发动的效果无效，并确认该卡仍在连锁中且可被破坏
	if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) and rc:IsDestructable()
		-- 检查己方场上有至少1只表侧表示的同调怪兽
		and Duel.IsExistingMatchingCard(s.cdfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否要破坏该张无效的卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否破坏？"
		-- 中断当前效果处理，使后续操作视为错时点
		Duel.BreakEffect()
		-- 将目标卡破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
