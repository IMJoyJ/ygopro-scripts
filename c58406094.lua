--煌めく聖夜
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽召唤。
-- ②：自己回合，自己场上的表侧表示的龙族·光属性·7星怪兽回到手卡的场合才能发动。自己从卡组抽1张。
function c58406094.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58406094,0))  --"使用「辉煌的圣夜」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(c58406094.extg)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己回合，自己场上的表侧表示的龙族·光属性·7星怪兽回到手卡的场合才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,58406094)
	e3:SetCondition(c58406094.drcon)
	e3:SetTarget(c58406094.drtg)
	e3:SetOperation(c58406094.drop)
	c:RegisterEffect(e3)
end
-- 过滤可以进行追加召唤的怪兽，需为「圣夜骑士」怪兽或者龙族·光属性·7星怪兽
function c58406094.extg(e,c)
	return c:IsSetCard(0x159) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsLevel(7))
end
-- 过滤回到手卡的卡片，需为自己场上表侧表示存在的龙族·光属性·7星怪兽
function c58406094.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsPreviousPosition(POS_FACEUP)
end
-- 发动条件：自己回合，且有满足条件的怪兽回到手卡
function c58406094.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合，且回到手卡的卡片中是否存在满足过滤条件的怪兽
	return eg:IsExists(c58406094.cfilter,1,nil,tp) and Duel.GetTurnPlayer()==tp
end
-- 效果发动的目标与操作信息：确认玩家是否能抽卡，并设置抽卡参数与操作信息
function c58406094.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的效果处理对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果处理参数（抽卡数量）设置为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：获取目标玩家和参数，执行抽卡操作
function c58406094.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
