--アロマージ－ジャスミン
-- 效果：
-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把「芳香法师-茉莉」以外的1只植物族怪兽召唤。
-- ②：1回合1次，自己基本分回复的场合发动。自己从卡组抽1张。
function c96789758.initial_effect(c)
	-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把「芳香法师-茉莉」以外的1只植物族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96789758,0))  --"使用「芳香法师-茉莉」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCondition(c96789758.excon)
	e1:SetTarget(c96789758.extg)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己基本分回复的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c96789758.drcon)
	e2:SetTarget(c96789758.drtg)
	e2:SetOperation(c96789758.drop)
	c:RegisterEffect(e2)
end
-- 判断是否满足额外召唤的条件（自己基本分比对方多）
function c96789758.excon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较双方基本分，返回自己基本分是否大于对方
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 过滤额外召唤的目标，必须是「芳香法师-茉莉」以外的植物族怪兽
function c96789758.extg(e,c)
	return c:IsRace(RACE_PLANT) and not c:IsCode(96789758)
end
-- 判断回复生命值的玩家是否为自己
function c96789758.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 抽卡效果的启动与目标设定，注册抽卡操作信息
function c96789758.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 向系统宣告此效果包含抽卡操作，数量为1张，操作玩家为自己
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果的具体处理
function c96789758.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
