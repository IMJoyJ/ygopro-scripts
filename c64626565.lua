--黒智天至イリスフィール
-- 效果：
-- 8星怪兽×2
-- 「黑智天至 伊里斯斐尔」1回合1次也能在这个回合没有在怪兽区域把效果发动的自己场上的超量怪兽上面重叠来超量召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡超量召唤的场合才能发动。这个回合的战斗阶段中，自己场上的超量怪兽的攻击力上升自身的阶级×100。
-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1个超量素材取除。
local s,id,o=GetID()
-- 初始化卡片效果，注册超量召唤手续、超量召唤成功时增加攻击力的诱发效果、破坏代替的永续效果，以及用于记录怪兽是否发动过效果的全局监听器
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,8,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。这个回合的战斗阶段中，自己场上的超量怪兽的攻击力上升自身的阶级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"增加攻击力"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 「黑智天至 伊里斯斐尔」1回合1次也能在这个回合没有在怪兽区域把效果发动的自己场上的超量怪兽上面重叠来超量召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		-- 注册全局环境下的效果，用于在连锁处理结束时记录在怪兽区域发动过效果的怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
-- 连锁处理结束时的操作：如果发动效果的卡是怪兽且在怪兽区域，则为其注册已发动效果的标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) then return end
	-- 获取当前处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_MZONE and rc:GetFlagEffect(id+o)==0 then
		rc:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤重叠超量召唤的素材：自己场上表侧表示、本回合没有在怪兽区域发动过效果的超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetFlagEffect(id+o)==0
end
-- 重叠超量召唤时的操作：检查并注册玩家本回合已使用过该特殊召唤方式的标记
function s.xyzop(e,tp,chk)
	-- 检查玩家本回合是否已经使用过该卡名特有的重叠超量召唤方式
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册本回合已使用过该重叠超量召唤方式的标记（1回合1次）
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检查此卡是否为超量召唤成功，且当前时点是否可以进行战斗相关操作
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
		-- 检查当前是否处于可以进入战斗阶段或正处于战斗阶段的时点
		and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 超量召唤成功时效果的处理：注册一个持续到回合结束的全局效果，使自己场上的超量怪兽在战斗阶段攻击力上升
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡超量召唤的场合才能发动。这个回合的战斗阶段中，自己场上的超量怪兽的攻击力上升自身的阶级×100。②：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1个超量素材取除。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.atkcon2)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使自己场上怪兽攻击力上升的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 攻击力上升效果的适用条件：当前处于战斗阶段
function s.atkcon2(e)
	-- 检查当前是否处于战斗阶段
	return Duel.IsBattlePhase()
end
-- 过滤攻击力上升效果的对象：超量怪兽
function s.atktg(e,c)
	return c:IsType(TYPE_XYZ)
end
-- 计算攻击力上升的数值：该怪兽的阶级 × 100
function s.atkval(e,c)
	return c:GetRank()*100
end
-- 破坏代替效果的准备：检查自身是否因战斗或效果被破坏，以及自己场上是否有可取除的超量素材
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在至少1个可以因效果取除的超量素材
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 取除自己场上的1个超量素材作为代替
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)
		return true
	else return false end
end
