--合体魔竜ティマイオス
-- 效果：
-- 「黑魔术师」或「黑魔术少女」＋龙族·魔法师族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤时适用。直到下次的自己回合的结束时，这张卡不受其他卡的效果影响。
-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力上升双方的墓地·除外状态的魔法卡数量×100。
-- ③：对方回合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化函数，注册融合召唤手续、特殊召唤成功时的抗性效果、伤害计算时增加攻击力的诱发效果、以及对方回合破坏魔法·陷阱卡的即时诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「黑魔术师」或「黑魔术少女」+ 1只龙族或魔法师族怪兽
	aux.AddFusionProcCodeFun(c,{46986414,38033121},aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON+RACE_SPELLCASTER),1,true,true)
	-- ①：这张卡特殊召唤时适用。直到下次的自己回合的结束时，这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetOperation(s.imop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力上升双方的墓地·除外状态的魔法卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"上升攻击力"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：对方回合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤融合素材是否为「黑魔术师」或「黑魔术少女」的辅助函数
function s.matfilter1(c)
	return c:IsCode(46986414) or c:IsCode(38033121)
end
-- 特殊召唤成功时效果的执行函数，为自身添加不受其他卡效果影响的抗性，并根据当前回合玩家设置持续时间
function s.imop(e,tp,eg,ep,ev,re,r,rp)
	-- 在决斗中展示该卡片，提示玩家该效果（不入连锁的效果）正在适用
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 直到下次的自己回合的结束时，这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"「合体魔龙 蒂迈欧」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	-- 判断当前是否为自己的回合，以此决定抗性效果的持续回合数
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	c:RegisterEffect(e1)
end
-- 免疫效果的过滤函数，使该卡不受除自身以外的其他卡片效果影响
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 过滤双方墓地及除外状态中表侧表示的魔法卡
function s.atkfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsFaceupEx()
end
-- 攻击力上升效果的发动条件及目标检查函数，确认双方墓地或除外状态是否存在魔法卡
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方墓地及除外状态中是否存在至少1张魔法卡
	if chk==0 then return Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)>0 end
end
-- 攻击力上升效果的执行函数，计算双方墓地和除外状态的魔法卡数量，并使该卡攻击力上升对应数值
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToChain() then return end
	-- 计算双方墓地及除外状态的魔法卡总数，并乘以100作为攻击力上升值
	local atk=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)*100
	-- 这张卡的攻击力上升双方的墓地·除外状态的魔法卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 破坏效果的发动条件函数，限制只能在对方回合发动
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 破坏效果的目标选择与检查函数，用于在场上选择1张魔法·陷阱卡作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理的操作信息，声明该效果包含“破坏场上1张卡”的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数，将选为对象的魔法·陷阱卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
