--殻醒する煉獄
-- 效果：
-- ①：1回合1次，自己准备阶段才能发动。从卡组把最多2只「狱火机」怪兽送去墓地。
-- ②：自己场上有「狱火机」怪兽以外的怪兽存在的场合这张卡送去墓地。
function c94432298.initial_effect(c)
	-- 开启全局标记以支持不入连锁的自我送墓检查
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己准备阶段才能发动。从卡组把最多2只「狱火机」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c94432298.tgcon)
	e2:SetTarget(c94432298.tgtg)
	e2:SetOperation(c94432298.tgop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「狱火机」怪兽以外的怪兽存在的场合这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_TOGRAVE)
	e3:SetCondition(c94432298.sdcon)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c94432298.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤卡组中「狱火机」怪兽且能送去墓地的卡的过滤函数
function c94432298.filter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动检测与效果处理信息设置函数
function c94432298.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94432298.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数
function c94432298.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1到2张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c94432298.filter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤里侧表示怪兽或非「狱火机」怪兽的过滤函数
function c94432298.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xbb)
end
-- 效果②的自我送墓条件判定函数
function c94432298.sdcon(e)
	-- 检查自己场上是否存在至少1只里侧表示怪兽或非「狱火机」怪兽
	return Duel.IsExistingMatchingCard(c94432298.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
