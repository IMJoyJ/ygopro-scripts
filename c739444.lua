--マガジンドラムゴン
-- 效果：
-- 龙族·暗属性怪兽3只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：这张卡的①的效果适用的回合只要这张卡在怪兽区域存在，作为这张卡所连接区的没有使用的怪兽区域不能使用。
function c739444.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要3只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c739444.matfilter,3,3)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(739444,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,739444)
	e1:SetTarget(c739444.drtg)
	e1:SetOperation(c739444.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果适用的回合只要这张卡在怪兽区域存在，作为这张卡所连接区的没有使用的怪兽区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c739444.discon)
	e2:SetValue(c739444.disval)
	c:RegisterEffect(e2)
end
-- 过滤连接素材：龙族且暗属性的怪兽
function c739444.matfilter(c)
	return c:IsLinkRace(RACE_DRAGON) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end
-- ①效果的发动准备与合法性检测（抽卡效果的目标与操作信息注册）
function c739444.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的处理：执行抽卡，并给自身注册一个表示“①效果已适用”的Flag
function c739444.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
	e:GetHandler():RegisterFlagEffect(739444,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
-- 检查自身是否带有表示“①效果已适用”的Flag，作为②效果生效的条件
function c739444.discon(e)
	return e:GetHandler():GetFlagEffect(739444)~=0
end
-- 获取这张卡所连接的区域，作为不能使用的怪兽区域
function c739444.disval(e)
	local c=e:GetHandler()
	return c:GetLinkedZone(0)
end
