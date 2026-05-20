--脳開発研究所
-- 效果：
-- ①：只要这张卡在场地区域存在，双方玩家在通常召唤外加上只有1次，自身的主要阶段可以把1只念动力族怪兽召唤。每次这个方法让念动力族怪兽召唤给这张卡放置1个念力指示物。
-- ②：自己场上的念动力族怪兽为让效果发动而支付基本分的场合，可以作为代替给这张卡放置1个念力指示物。
-- ③：这张卡从场上离开时自己受到这张卡放置的念力指示物数量×1000伤害。
function c85668449.initial_effect(c)
	c:EnableCounterPermit(0x4)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，双方玩家在通常召唤外加上只有1次，自身的主要阶段可以把1只念动力族怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85668449,1))  --"使用「脑开发研究所」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置增加召唤次数效果的目标为念动力族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PSYCHO))
	e2:SetOperation(c85668449.esop)
	c:RegisterEffect(e2)
	-- 每次这个方法让念动力族怪兽召唤给这张卡放置1个念力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c85668449.ctcon)
	e3:SetOperation(c85668449.ctop)
	c:RegisterEffect(e3)
	-- ②：自己场上的念动力族怪兽为让效果发动而支付基本分的场合，可以作为代替给这张卡放置1个念力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85668449,0))  --"给「脑开发研究所」放置1个「念力指示物」"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_LPCOST_REPLACE)
	e3:SetCondition(c85668449.lrcon)
	e3:SetOperation(c85668449.lrop)
	c:RegisterEffect(e3)
	-- ③：这张卡从场上离开时自己受到这张卡放置的念力指示物数量×1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c85668449.damp)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上离开时自己受到这张卡放置的念力指示物数量×1000伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(c85668449.damop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 在通过此效果召唤的怪兽上注册一个标记，用于后续判定是否是通过该效果召唤
function c85668449.esop(e,tp,eg,ep,ev,re,r,rp,c)
	c:RegisterFlagEffect(85668449,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查召唤成功的怪兽是否带有通过此卡效果召唤的标记
function c85668449.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetFlagEffect(85668449)~=0
end
-- 给这张卡放置1个念力指示物，并清除该怪兽的召唤标记
function c85668449.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x4,1)
	eg:GetFirst():ResetFlagEffect(85668449)
end
-- 检查是否是自己场上的念动力族怪兽发动效果且需要支付基本分作为代价
function c85668449.lrcon(e,tp,eg,ep,ev,re,r,rp)
	if tp~=ep then return false end
	-- 获取当前需要支付基本分的玩家的生命值
	local lp=Duel.GetLP(ep)
	if lp<ev then return false end
	if not re or not re:IsActivated() then return false end
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and rc:IsRace(RACE_PSYCHO)
end
-- 作为代替，给这张卡放置1个念力指示物
function c85668449.lrop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x4,1)
end
-- 在这张卡即将离场前，记录其上放置的念力指示物数量
function c85668449.damp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x4)
	e:SetLabel(ct)
end
-- 在这张卡离场时，根据之前记录的指示物数量，给控制者造成对应数值的伤害
function c85668449.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if ct>0 then
		-- 给予玩家等同于指示物数量×1000数值的效果伤害
		Duel.Damage(tp,ct*1000,REASON_EFFECT)
	end
end
