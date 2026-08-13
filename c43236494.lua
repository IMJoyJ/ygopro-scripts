--Fairy Tale 序章 旅立ちの暁光
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，双方受到的战斗伤害变成一半。
-- ②：自己场上有兽族·光属性怪兽或者7·8星的龙族同调怪兽存在的场合才能发动。自己抽1张。
-- ③：自己准备阶段，把场地区域的这张卡送去墓地才能发动。从自己的手卡·卡组把「童话故事 序章 启程的曙光」以外的1张场地魔法卡在自己的场地区域表侧表示放置。
local s,id,o=GetID()
-- 为该卡注册效果：e1为场地魔法卡发动用自由时点效果；e2为①双方战斗伤害减半；e3为②自己抽1张（含此卡名②效果1回合1次限制）；e4为③自己准备阶段送墓后检索放置其他场地魔法卡。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，双方受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有兽族·光属性怪兽或者7·8星的龙族同调怪兽存在的场合才能发动。自己抽1张。
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
	-- ③：自己准备阶段，把场地区域的这张卡送去墓地才能发动。从自己的手卡·卡组把「童话故事 序章 启程的曙光」以外的1张场地魔法卡在自己的场地区域表侧表示放置。
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
-- 定义过滤函数，筛选自己场上表侧表示且满足②发动条件的怪兽：兽族·光属性怪兽，或7·8星龙族同调怪兽。
function s.drfilter(c)
	return c:IsFaceup()
		and (c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT)
		or c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(7,8))
end
-- ②效果的发动条件：检查自己场上是否存在至少1只满足s.drfilter的怪兽。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己怪兽区域检查是否存在至少1张符合条件的怪兽卡。
	return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标处理：检查能否抽卡，设置目标玩家为自己、参数为1，并登记抽卡操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己是否可以抽1张卡，若不能则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁目标玩家设置为自己，表示抽卡对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁目标参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：该效果为抽卡类别，目标玩家为自己，参数为1（targets为nil表示不指定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从连锁信息取出目标玩家和数量并执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家（抽卡对象）和参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：只有自己准备阶段（当前回合玩家是自己）才能发动。
function s.faccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者自己，即是否为自己准备阶段。
	return tp==Duel.GetTurnPlayer()
end
-- ③效果的发动代价：检查并执行把这张卡自身送去墓地作为cost。
function s.faccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将场地区域的这张卡自身作为cost送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义过滤函数：筛选「童话故事 序章 启程的曙光」以外的场地魔法卡，要求不是禁止卡且该卡名在场上只能存在1张。
function s.pfilter(c,tp)
	return not c:IsCode(id) and not c:IsForbidden() and c:IsType(TYPE_FIELD) and c:CheckUniqueOnField(tp)
end
-- ③效果的目标合法性检查：确认手卡·卡组中存在至少1张满足s.pfilter的场地魔法卡。
function s.factg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡和卡组中是否存在至少1张符合条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end
-- ③效果处理：选择1张符合条件的场地魔法卡，若场地区域已有卡则先将旧场地卡以规则原因送墓并中断效果，再将新场地卡表侧表示放置到自己的场地区域。
function s.facop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求选择一张要放置到场地区域的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡·卡组中选择1张满足条件的场地魔法卡并取得该卡。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域当前放置的卡（若存在）。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将原有场地魔法卡以规则原因送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续的放置动作视为不同时处理。
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法卡以表侧表示放置到自己的场地区域，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
