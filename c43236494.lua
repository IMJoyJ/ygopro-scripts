--Fairy Tale 序章 旅立ちの暁光
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，双方受到的战斗伤害变成一半。
-- ②：自己场上有兽族·光属性怪兽或者7·8星的龙族同调怪兽存在的场合才能发动。自己抽1张。
-- ③：自己准备阶段，把场地区域的这张卡送去墓地才能发动。从自己的手卡·卡组把「童话故事 序章 启程的曙光」以外的1张场地魔法卡在自己的场地区域表侧表示放置。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的激活、战斗伤害减半、抽卡和准备阶段放置场地魔法卡的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场地区域存在，双方受到的战斗伤害变成一半
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	-- 自己场上有兽族·光属性怪兽或者7·8星的龙族同调怪兽存在的场合才能发动。自己抽1张
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	-- 自己准备阶段，把场地区域的这张卡送去墓地才能发动。从自己的手卡·卡组把「童话故事 序章 启程的曙光」以外的1张场地魔法卡在自己的场地区域表侧表示放置
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"表侧表示放置场地魔法卡"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCondition(s.faccon)
	e4:SetCost(s.faccost)
	e4:SetTarget(s.factg)
	e4:SetOperation(s.facop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（兽族·光属性或7·8星龙族同调怪兽）
function s.drfilter(c)
	return c:IsFaceup()
		and (c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT)
		or c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(7,8))
end
-- 判断条件函数，检查场上是否存在满足drfilter条件的怪兽
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足drfilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置抽卡效果的目标和操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标参数为1张
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果的操作函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 准备阶段触发条件函数，判断是否为当前回合玩家
function s.faccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置准备阶段放置场地魔法卡效果的费用函数
function s.faccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选可以放置的场地魔法卡
function s.pfilter(c,tp)
	return not c:IsCode(id) and not c:IsForbidden() and c:IsType(TYPE_FIELD) and c:CheckUniqueOnField(tp)
end
-- 设置准备阶段放置场地魔法卡效果的目标函数
function s.factg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡和卡组中是否存在满足pfilter条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end
-- 执行准备阶段放置场地魔法卡效果的操作函数
function s.facop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场地区的场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取当前玩家场地区域的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将旧的场地魔法卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡移动到场地区域并表侧表示
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
