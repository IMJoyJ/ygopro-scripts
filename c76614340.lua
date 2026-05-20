--ジェムナイト・ルビーズ
-- 效果：
-- 「宝石骑士·红榴」＋「宝石骑士」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，把自己场上1只其他的表侧表示的「宝石」怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的攻击力数值。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c76614340.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为卡名是「宝石骑士·红榴」（91731841）的怪兽和1只「宝石骑士」（0x1047）怪兽
	aux.AddFusionProcCodeFun(c,91731841,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c76614340.splimit)
	c:RegisterEffect(e2)
	-- ①：1回合1次，把自己场上1只其他的表侧表示的「宝石」怪兽解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76614340,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c76614340.atkcost)
	e3:SetOperation(c76614340.atkop)
	c:RegisterEffect(e3)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
end
-- 限制从额外卡组特殊召唤时必须是融合召唤
function c76614340.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 过滤场上表侧表示的「宝石」怪兽
function c76614340.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x47)
end
-- 攻击力上升效果的发动代价：检查并解放场上1只其他的表侧表示「宝石」怪兽，并记录其攻击力
function c76614340.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除自身以外、可解放的表侧表示「宝石」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c76614340.costfilter,1,e:GetHandler()) end
	-- 选择场上除自身以外的1只表侧表示「宝石」怪兽
	local rg=Duel.SelectReleaseGroup(tp,c76614340.costfilter,1,1,e:GetHandler())
	e:SetLabel(rg:GetFirst():GetAttack())
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- 攻击力上升效果的执行：使自身攻击力直到回合结束时上升被解放怪兽的攻击力数值
function c76614340.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到回合结束时上升解放的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
