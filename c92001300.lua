--古代の機械城
-- 效果：
-- ①：场上的「古代的机械」怪兽的攻击力上升300。
-- ②：只要这张卡在魔法与陷阱区域存在，每次怪兽通常召唤，给这张卡放置1个指示物。
-- ③：自己把「古代的机械」怪兽表侧表示上级召唤的场合，可以把有需要的解放数量以上的指示物放置的这张卡作为代替而解放来上级召唤。
function c92001300.initial_effect(c)
	c:EnableCounterPermit(0xb)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「古代的机械」怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置攻击力上升效果的影响对象为「古代的机械」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，每次怪兽通常召唤，给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c92001300.addc)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_MSET)
	c:RegisterEffect(e4)
	-- ③：自己把「古代的机械」怪兽表侧表示上级召唤的场合，可以把有需要的解放数量以上的指示物放置的这张卡作为代替而解放来上级召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(92001300,0))  --"解放「古代的机械城」进行通常召唤"
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	-- 设置代替解放召唤手续适用于手牌中的「古代的机械」怪兽
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7))
	e4:SetCondition(c92001300.sumcon)
	e4:SetOperation(c92001300.sumop)
	e4:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e4)
end
-- 每次怪兽通常召唤成功时，给这张卡放置1个指示物
function c92001300.addc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xb,1)
end
-- 代替解放上级召唤的条件判断函数
function c92001300.sumcon(e,c,minc)
	if c==nil then return e:GetHandler():IsReleasable(REASON_SUMMON) end
	local mi,ma=c:GetTributeRequirement()
	if mi<minc then mi=minc end
	if ma<mi then return false end
	-- 判断怪兽所需解放数大于0、此卡指示物数量足够且召唤玩家场上有可用的怪兽区域
	return ma>0 and e:GetHandler():GetCounter(0xb)>=mi and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 代替解放上级召唤的具体操作函数
function c92001300.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	c:SetMaterial(Group.FromCards(e:GetHandler()))
	-- 将此卡作为上级召唤的素材解放
	Duel.Release(e:GetHandler(),REASON_SUMMON+REASON_MATERIAL)
end
