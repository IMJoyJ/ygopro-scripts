--セベクの魔導士
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡或者这张卡所连接区的自己怪兽给与对方战斗伤害时才能发动。自己基本分回复那个数值。
-- ②：自己或对方的基本分回复的场合才能发动（伤害步骤也能发动）。双方受到1000伤害。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片的苏生限制并添加连接召唤手续，创建两个诱发效果和一个触发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2只效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- 效果①：当自己或连接区怪兽造成战斗伤害时发动，回复相当于伤害数值的生命值
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
	-- 效果②：自己或对方回复生命值时发动，双方各受到1000伤害
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
-- 用于判断是否为连接区怪兽的辅助函数
function s.recfilter(c,lg)
	return lg:IsContains(c)
end
-- 效果①的发动条件：对方造成战斗伤害且伤害来源为自身或连接区怪兽
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return ep~=tp and eg:IsExists(s.recfilter,1,nil,lg)
end
-- 效果②的发动条件：对方造成战斗伤害
function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果①的发动时处理，设置目标玩家和参数，准备回复生命值
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁目标参数为伤害值
	Duel.SetTargetParam(ev)
	-- 设置操作信息为回复生命值效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果①的处理函数，根据连锁信息回复生命值
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因回复目标玩家指定数值的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 效果②的发动条件：自己或对方回复生命值
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp or 1-tp
end
-- 效果②的发动时处理，设置目标玩家和参数，准备造成伤害
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁目标玩家为双方
	Duel.SetTargetPlayer(tp and 1-tp)
	-- 设置连锁目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息为双方各受到1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果②的处理函数，双方各受到1000伤害并完成伤害步骤
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方受到1000伤害
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	-- 使自己受到1000伤害
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	-- 完成伤害步骤的处理
	Duel.RDComplete()
end
