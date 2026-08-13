--CiNo.1000 夢幻虚光神ヌメロニアス・ヌメロニア
-- 效果：
-- 13星怪兽×5
-- ①：「混沌No.1000 梦幻虚神 原数天灵」的效果特殊召唤的这张卡攻击力·守备力只在对方回合内上升100000，从特殊召唤的下个回合起以下适用。
-- ●可以攻击的对方怪兽必须向这张卡作出攻击。
-- ●这张卡没有进行战斗的对方回合结束时，自己决斗胜利。
-- ②：对方怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效，自己基本分回复那个攻击力的数值。
function c15862758.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以等级13的怪兽5只为素材进行超量召唤（对应效果原文‘13星怪兽×5’）。
	aux.AddXyzProcedure(c,nil,13,5)
	c:EnableReviveLimit()
	-- ①：「混沌No.1000 梦幻虚神 原数天灵」的效果特殊召唤的这张卡攻击力·守备力只在对方回合内上升100000，从特殊召唤的下个回合起以下适用。●可以攻击的对方怪兽必须向这张卡作出攻击。●这张卡没有进行战斗的对方回合结束时，自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c15862758.condition)
	e1:SetOperation(c15862758.operation)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效，自己基本分回复那个攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15862758,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c15862758.nacon)
	e2:SetCost(c15862758.nacost)
	e2:SetTarget(c15862758.natg)
	e2:SetOperation(c15862758.naop)
	c:RegisterEffect(e2)
end
-- 将这张卡的卡号登记到混沌XYZ编号1000（aux.xyz_number），用于后续其它卡效果识别/联动。
aux.xyz_number[15862758]=1000
-- 特殊召唤成功时的触发条件：诱发效果来源必须为卡号89477759（即「混沌No.1000 梦幻虚神 原数天灵」）的效果，确认本卡是由其效果特殊召唤。
function c15862758.condition(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(89477759)
end
-- 特殊召唤成功时执行：给这张卡附加“仅对方回合攻守上升100000”的永续效果，并设置从下个回合起使对方怪兽必须攻击此卡、且此卡未进行战斗的对方回合结束时己方决斗胜利的效果。
function c15862758.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local turn=c:GetTurnID()
	-- 攻击力·守备力只在对方回合内上升100000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c15862758.atkcon)
	e1:SetValue(100000)
	e1:SetReset(RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ●可以攻击的对方怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c15862758.effcon)
	e2:SetLabel(turn)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c15862758.atklimit)
	c:RegisterEffect(e3)
	-- ●这张卡没有进行战斗的对方回合结束时，自己决斗胜利。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TURN_END)
	e4:SetCondition(c15862758.wincon)
	e4:SetOperation(c15862758.winop)
	e4:SetLabel(turn)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
end
-- 攻击力/守备力上升的适用条件：当前回合是这张卡操控者的对手的回合（即对方回合）。
function c15862758.atkcon(e)
	-- 判断当前回合玩家不是这张卡的操控者，即满足‘只在对方回合内’。
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
-- 强制攻击/胜利效果的适用条件：当前回合数已到达这张卡特殊召唤的下一回合及之后，满足‘从特殊召唤的下个回合起’。
function c15862758.effcon(e)
	-- 用当前回合数与特殊召唤时的回合数比较，确认已过特殊召唤后的下个回合。
	return Duel.GetTurnCount()>=e:GetLabel()+1
end
-- 指定强制攻击的对象为此卡自身：当攻击目标为这张卡时返回true，使对方怪兽必须向此卡攻击。
function c15862758.atklimit(e,c)
	return c==e:GetHandler()
end
-- 胜利触发条件：对方回合、此卡本回合没有进行过战斗、且已过特殊召唤下个回合，三项同时满足。
function c15862758.wincon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：当前是对方回合、这张卡的战斗组计数为0（未进行战斗）、并且已满足‘从特殊召唤的下个回合起’。
	return Duel.GetTurnPlayer()==1-tp and e:GetHandler():GetBattledGroupCount()==0 and c15862758.effcon(e)
end
-- 胜利效果的处理：设置专属胜利原因代码并调用Duel.Win令此卡操控者决斗胜利。
function c15862758.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_NUMERONIUS_NUMERONIA=0x21
	-- 直接令此卡操控者以指定胜利原因赢得本场决斗。
	Duel.Win(tp,WIN_REASON_NUMERONIUS_NUMERONIA)
end
-- ②效果的发动条件：攻击宣言的怪兽是对方怪兽（攻击者控制者为1-tp）。
function c15862758.nacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击宣言的怪兽的控制者是对手玩家，即只有对方怪兽攻击时才能发动②。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ②效果的发动代价：检查此卡有1个超量素材可去除；发动时去除1个超量素材（REASON_COST）。
function c15862758.nacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的发动目标：获取攻击怪兽，确认其仍与战斗相关且表侧表示，并设置回复LP的操作信息。
function c15862758.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的怪兽。
	local b=Duel.GetAttacker()
	if chk==0 then return b and b:IsRelateToBattle() and b:IsFaceup() end
	-- 设置操作信息：本次效果处理将给此卡操控者回复LP，数值为攻击怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,b:GetAttack())
end
-- ②效果处理：无效攻击；若攻击怪兽仍存在于场上且表侧表示，则回复其攻击力数值的LP。
function c15862758.naop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次取得当前攻击宣言的怪兽。
	local b=Duel.GetAttacker()
	-- 若攻击无效成功（Duel.NegateAttack返回true）且攻击怪兽仍与战斗相关并表侧表示，则继续执行回复。
	if Duel.NegateAttack() and b and b:IsRelateToBattle() and b:IsFaceup() then
		-- 回复此卡操控者LP，数值等于攻击怪兽的攻击力（REASON_EFFECT）。
		Duel.Recover(tp,b:GetAttack(),REASON_EFFECT)
	end
end
