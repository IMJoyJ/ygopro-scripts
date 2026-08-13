--セベクの魔導士
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡或者这张卡所连接区的自己怪兽给与对方战斗伤害时才能发动。自己基本分回复那个数值。
-- ②：自己或对方的基本分回复的场合才能发动（伤害步骤也能发动）。双方受到1000伤害。
local s,id,o=GetID()
-- 怪兽的初始化：设置苏生限制、连接召唤规则（2只效果怪兽），并注册①效果（自身或连接区怪兽造成战斗伤害时回复）和②效果（回复发生时双方各受1000伤害），同时用不同计数代码分别限制①和②每回合只能使用1次。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只效果怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- ①：这张卡或者这张卡所连接区的自己怪兽给与对方战斗伤害时才能发动。自己基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.reccon1)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(s.reccon2)
	c:RegisterEffect(e2)
	-- ②：自己或对方的基本分回复的场合才能发动（伤害步骤也能发动）。双方受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"双方受到1000伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片c是否存在于连接区怪兽组lg中，用于筛选造成战斗伤害的怪兽是否位于本卡的连接区。
function s.recfilter(c,lg)
	return lg:IsContains(c)
end
-- ①效果（连接区怪兽部分）的发动条件：受到战斗伤害的是对方（ep~=tp），且造成伤害的怪兽中存在至少1只位于本卡连接区的怪兽。
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return ep~=tp and eg:IsExists(s.recfilter,1,nil,lg)
end
-- ①效果（本卡自身部分）的发动条件：这张卡自身给与对方战斗伤害（受伤玩家是对方，即ep~=tp）。
function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ①效果的发动时目标处理：判定可以发动后，将回复目标玩家设为本方，回复数值设为这次战斗伤害的数值，并写入回复效果的操作信息。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为本方，指定由本方回复基本分。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为战斗伤害数值ev，作为回复量。
	Duel.SetTargetParam(ev)
	-- 设置操作信息为回复效果：回复对象为本方，回复量为ev，供其他卡片（如星尘龙等）进行效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- ①效果处理：从连锁信息中取出之前保存的目标玩家和回复量，执行基本分回复。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁保存的目标玩家p和回复参数d（回复量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- ②效果的发动条件：自己或对方的基本分回复的场合（任一玩家回复LP时）满足条件，且伤害步骤也能发动。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp or 1-tp
end
-- ②效果的发动时目标处理：设置伤害对象为双方、伤害数值为1000，并写入伤害效果的操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家（表示伤害对象涉及对方）。
	Duel.SetTargetPlayer(tp and 1-tp)
	-- 将当前连锁的对象参数设为1000，即伤害数值。
	Duel.SetTargetParam(1000)
	-- 设置操作信息为伤害效果：对象为双方玩家，伤害值为1000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- ②效果处理：对双方各造成1000点效果伤害，使用分步处理以正确触发伤害/回复相关时点。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家造成1000点效果伤害（is_step=true，作为伤害/回复分解过程的一部分）。
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 给自己玩家造成1000点效果伤害（is_step=true）。
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	-- 完成伤害/回复过程的分解处理，触发对应的时点。
	Duel.RDComplete()
end
