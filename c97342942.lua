--エクトプラズマー
-- 效果：
-- 双方玩家各自在自己的结束阶段时只有1次，选自己场上表侧表示存在的1只怪兽，把那只怪兽解放，给与对方基本分解放的那只怪兽的原本攻击力一半数值的伤害。
function c97342942.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 双方玩家各自在自己的结束阶段时只有1次，选自己场上表侧表示存在的1只怪兽，把那只怪兽解放，给与对方基本分解放的那只怪兽的原本攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97342942,0))  --"解放并伤害"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c97342942.condition)
	e2:SetTarget(c97342942.target)
	e2:SetOperation(c97342942.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数，限制在自己的结束阶段发动
function c97342942.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为当前效果的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果发动时的目标确认与操作信息设置函数
function c97342942.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明该效果在处理时会解放怪兽区的一张卡
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
end
-- 定义过滤函数，筛选场上表侧表示且不免疫该效果的怪兽
function c97342942.rfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
-- 定义效果处理函数，执行解放怪兽并给与对方伤害的操作
function c97342942.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让当前玩家选择自己场上1只满足条件的怪兽作为解放的对象
	local rg=Duel.SelectReleaseGroupEx(tp,c97342942.rfilter,1,1,REASON_EFFECT,false,e:GetHandler(),e)
	-- 将选中的怪兽因效果解放，并确认是否成功解放
	if Duel.Release(rg,REASON_EFFECT)>0 then
		local atk=math.floor(rg:GetFirst():GetBaseAttack()/2)
		-- 给与对方玩家等同于被解放怪兽原本攻击力一半数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
