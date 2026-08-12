--闇黒の夢魔鏡
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有暗属性「梦魔镜」怪兽存在，每次对方对怪兽的特殊召唤成功，给与对方300伤害。
-- ②：自己·对方的结束阶段，把自己的场地区域的这张卡除外才能发动。从手卡·卡组把1张「圣光之梦魔镜」发动。
function c1050355.initial_effect(c)
	-- 为卡片注册与「圣光之梦魔镜」相关的卡片代码，用于后续效果判断
	aux.AddCodeList(c,74665651)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把自己的场地区域的这张卡除外才能发动。从手卡·卡组把1张「圣光之梦魔镜」发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1050355,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,1050355)
	-- 设置效果发动的费用为将自身除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c1050355.acttg)
	e2:SetOperation(c1050355.actop)
	c:RegisterEffect(e2)
	-- ①：只要自己场上有暗属性「梦魔镜」怪兽存在，每次对方对怪兽的特殊召唤成功，给与对方300伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c1050355.damcon)
	e3:SetOperation(c1050355.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡或卡组中是否存在可发动的「圣光之梦魔镜」卡片
function c1050355.actfilter(c,tp)
	return c:IsCode(74665651) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果的发动条件判断，检查是否存在满足条件的「圣光之梦魔镜」卡片
function c1050355.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「圣光之梦魔镜」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c1050355.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 处理效果发动时的逻辑，包括选择卡片、替换场地卡、移动卡片到场地区域并激活其效果
function c1050355.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	-- 从手卡或卡组中选择一张「圣光之梦魔镜」卡片
	local tc=Duel.SelectMatchingCard(tp,c1050355.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取玩家场地区域当前存在的卡片
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将场地区域的旧卡片送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理流程，使后续处理视为不同时处理
			Duel.BreakEffect()
		end
		-- 将选中的卡片移动到场地区域
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发选中的卡片的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 过滤函数，用于判断场上是否存在暗属性的「梦魔镜」怪兽
function c1050355.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x131) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤函数，用于判断召唤的怪兽是否为对方召唤的
function c1050355.cfilter2(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断是否满足触发条件，即己方场上有暗属性「梦魔镜」怪兽且对方有怪兽特殊召唤成功
function c1050355.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在满足条件的暗属性「梦魔镜」怪兽
	return Duel.IsExistingMatchingCard(c1050355.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(c1050355.cfilter2,1,nil,1-tp)
end
-- 处理伤害效果，给与对方300点伤害
function c1050355.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示发动了「黯黑之梦魔镜」的效果
	Duel.Hint(HINT_CARD,0,1050355)
	-- 给与对方300点伤害
	Duel.Damage(1-tp,300,REASON_EFFECT)
end
