--パラライズ・チェーン
-- 效果：
-- 每次卡的效果从对方卡组把卡送去墓地，给与对方基本分300伤害。
function c79707116.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次卡的效果从对方卡组把卡送去墓地，给与对方基本分300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79707116,0))  --"伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c79707116.damcon)
	e2:SetTarget(c79707116.damtg)
	e2:SetOperation(c79707116.damop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡片原本在卡组且原本的控制者为指定玩家
function c79707116.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 发动条件：存在卡片因卡的效果从对方卡组送去墓地
function c79707116.damcon(e,tp,eg,ep,ev,re,r,rp)
	return re and bit.band(r,REASON_EFFECT)~=0 and eg:IsExists(c79707116.cfilter,1,nil,1-tp)
end
-- 效果发动时的目标处理：设置对方为伤害对象，伤害数值为300，并注册伤害操作信息
function c79707116.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的对象参数为300
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为给与对方300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果处理：获取设定的对象玩家和伤害数值，并给与该玩家对应的效果伤害
function c79707116.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以卡的效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
