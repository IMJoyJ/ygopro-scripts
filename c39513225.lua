--七皇の冀望郷
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在场地区域存在，那个期间双方1回合只能有最多2次把「No.」怪兽以外的怪兽从额外卡组特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1只「阴影」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ③：自己·对方的结束阶段发动。双方受到场上的超量怪兽数量×400伤害。
local s,id,o=GetID()
-- 初始化卡片效果：注册场地卡的发动空效果（e1）、记录双方从额外卡组特殊召唤次数的永续效果（e2）、限制双方1回合最多2次特殊召唤「No.」以外的额外卡组怪兽的永续效果（e3）、检索「阴影」怪兽的起动效果（e5，1回合1次）和结束阶段给予双方伤害的诱发必发效果（e6，1回合1次）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，那个期间双方1回合只能有最多2次把「No.」怪兽以外的怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.count)
	c:RegisterEffect(e2)
	-- 双方1回合只能有最多2次把「No.」怪兽以外的怪兽从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
	-- ②：自己主要阶段才能发动。从卡组把1只「阴影」怪兽加入手卡。那之后，选自己1张手卡丢弃。（1回合只能使用1次）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"检索"
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	-- ③：自己·对方的结束阶段发动。双方受到场上的超量怪兽数量×400伤害。（1回合只能使用1次）
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))  --"受到伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_FZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCountLimit(1,id+o)
	e6:SetTarget(s.damtg)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
-- 过滤函数：判断该卡是否为玩家tp从额外卡组特殊召唤的「No.」系列以外的怪兽
function s.cfilter(c,tp)
	return not c:IsSetCard(0x48) and c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 特殊召唤成功时，分别检查双方玩家本次特殊召唤中是否存在「No.」以外的额外卡组怪兽，若有则给这张卡登记对应玩家的计数标记（回合结束时重置）
function s.count(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.cfilter,1,nil,p) then
			e:GetHandler():RegisterFlagEffect(id+p*100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 限制判断：若该怪兽在额外卡组且不是「No.」系列，且召唤方本回合的计数标记已超过1（即这将是第3次），则禁止这次特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x48)
		and e:GetHandler():GetFlagEffect(id+sump*100)>1
end
-- 过滤函数：检索可以加入手卡的「阴影」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的对象设定：检查卡组是否存在可加入手卡的「阴影」怪兽，并设置将从卡组把1张卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组存在至少1只可以加入手卡的「阴影」怪兽才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡（目标卡在处理时才确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：让玩家从卡组选1只「阴影」怪兽加入手卡，给对方确认后，中断效果处理，再选1张手卡洗切后丢弃去墓地
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「阴影」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若选到了卡且成功以效果加入手卡（该卡确实在手卡），则继续后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 把加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使之后的丢弃与前面的检索视为不同时处理（错开时点）
		Duel.BreakEffect()
		-- 让玩家从自己的手卡选择1张可以丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切自己的手卡（隐藏被丢弃卡的位置信息）
		Duel.ShuffleHand(tp)
		-- 把选中的手卡以效果丢弃送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤函数：判断该卡是否为场上表侧表示的超量怪兽
function s.damfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ③效果的对象设定：必发效果无需发动条件，计算双方场上表侧表示的超量怪兽数量×400的伤害值并设置操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算伤害值：双方场上表侧表示的超量怪兽数量×400
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*400
	-- 设置操作信息：将对双方玩家造成计算出的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- ③效果的处理：重新计算双方场上超量怪兽数量×400的伤害值，分步给予双方玩家该数值的伤害，然后触发伤害处理的时点
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算伤害值：双方场上表侧表示的超量怪兽数量×400
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*400
	-- 给予发动方玩家该数值的效果伤害（分步处理）
	Duel.Damage(tp,dam,REASON_EFFECT,true)
	-- 给予对方玩家该数值的效果伤害（分步处理）
	Duel.Damage(1-tp,dam,REASON_EFFECT,true)
	-- 完成分步伤害处理，触发伤害相关的时点
	Duel.RDComplete()
end
