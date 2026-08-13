--闇黒の夢魔鏡
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有暗属性「梦魔镜」怪兽存在，每次对方对怪兽的特殊召唤成功，给与对方300伤害。
-- ②：自己·对方的结束阶段，把自己的场地区域的这张卡除外才能发动。从手卡·卡组把1张「圣光之梦魔镜」发动。
function c1050355.initial_effect(c)
	-- 将该卡上记载的卡名「圣光之梦魔镜」（卡号74665651）加入代码列表，用于后续判断/检索同名卡
	aux.AddCodeList(c,74665651)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 『这个卡名的②的效果1回合只能使用1次。②：自己·对方的结束阶段，把自己的场地区域的这张卡除外才能发动。从手卡·卡组把1张「圣光之梦魔镜」发动。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1050355,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,1050355)
	-- 设置②效果的发动代价：把场地区域的这张卡除外（aux.bfgcost实现）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c1050355.acttg)
	e2:SetOperation(c1050355.actop)
	c:RegisterEffect(e2)
	-- 『①：只要自己场上有暗属性「梦魔镜」怪兽存在，每次对方对怪兽的特殊召唤成功，给与对方300伤害。』
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c1050355.damcon)
	e3:SetOperation(c1050355.damop)
	c:RegisterEffect(e3)
end
-- 定义选择「圣光之梦魔镜」的过滤条件：卡名正确，且其魔法卡的发动效果在当前状态下可以发动
function c1050355.actfilter(c,tp)
	return c:IsCode(74665651) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- ②效果的发动条件判断：仅在从手卡·卡组能找到可发动的「圣光之梦魔镜」时才可发动
function c1050355.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查（chk==0）时，确认手卡·卡组存在至少1张满足过滤条件的「圣光之梦魔镜」
	if chk==0 then return Duel.IsExistingMatchingCard(c1050355.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- ②效果处理时的操作：从手卡·卡组选出1张「圣光之梦魔镜」，处理旧场地，将选出的卡放上场地区域并发动其效果
function c1050355.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，提示内容为“请选择要放置到场上的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡·卡组选择1张满足actfilter的「圣光之梦魔镜」并取得所选卡
	local tc=Duel.SelectMatchingCard(tp,c1050355.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域第0格的卡（即当前表侧存在的场地魔法）
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将已有的旧场地魔法以规则理由送去墓地，为新场地让出位置
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续放置新场地及发动等操作与之前送墓视为不同时处理，避免错过时点
			Duel.BreakEffect()
		end
		-- 将选择的「圣光之梦魔镜」移动到自己场地区域并表侧表示放置，同时使其效果立刻适用
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 以该卡触发魔法卡发动时点（EVENT_CHAINING），使引擎处理这张「圣光之梦魔镜」的发动
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 定义①效果中“自己场上有暗属性「梦魔镜」怪兽”的判定条件：表侧表示、属于0x131系列、暗属性
function c1050355.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x131) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 定义“对方对怪兽的特殊召唤成功”的判定条件：该怪兽的召唤玩家是对手（1-tp）
function c1050355.cfilter2(c,tp)
	return c:IsSummonPlayer(tp)
end
-- ①效果的发动条件：自己场上有暗属性「梦魔镜」怪兽，且本次对方特殊召唤成功
function c1050355.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的暗属性「梦魔镜」怪兽
	return Duel.IsExistingMatchingCard(c1050355.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(c1050355.cfilter2,1,nil,1-tp)
end
-- ①效果处理时的操作：给对方造成300点伤害，并展示卡片动画
function c1050355.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示本卡（1050355）的发动动画，让双方看到是该卡的效果伤害
	Duel.Hint(HINT_CARD,0,1050355)
	-- 给与对方玩家（1-tp）300点效果伤害
	Duel.Damage(1-tp,300,REASON_EFFECT)
end
