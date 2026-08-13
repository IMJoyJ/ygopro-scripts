--アルティメットサイキッカー
-- 效果：
-- 念动力族同调怪兽＋念动力族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡只要在怪兽区域存在，不会被效果破坏。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c40101111.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册该卡的融合召唤手续：以1只念动力族同调怪兽和1只念动力族怪兽为融合素材，使这张卡可通过融合召唤从额外卡组特殊召唤。
	aux.AddFusionProcFun2(c,c40101111.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),true)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ①：这张卡只要在怪兽区域存在，不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40101111,0))  --"回复破坏的怪兽的攻击力的数值"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c40101111.recon)
	e4:SetTarget(c40101111.rectg)
	e4:SetOperation(c40101111.recop)
	c:RegisterEffect(e4)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c40101111.splimit)
	c:RegisterEffect(e5)
end
c40101111.material_type=TYPE_SYNCHRO
-- 特殊召唤限制的判定函数：若这张卡在额外卡组，则只有融合召唤方式才能将其特殊召唤；若不在额外卡组则不做额外限制。
function c40101111.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 融合素材过滤函数：判断该卡是否为念动力族同调怪兽（种族为念动力且可作为融合素材时视为同调怪兽）。
function c40101111.ffilter(c)
	return c:IsFusionType(TYPE_SYNCHRO) and c:IsRace(RACE_PSYCHO)
end
-- 战斗破坏触发条件：确认这张卡的战斗对象是被其战斗破坏并已送入墓地的怪兽，以此判定③效果的发动时机。
function c40101111.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 回复效果发动时的目标设定：将回复LP的玩家设为这张卡的控制者，回复量设为被战斗破坏怪兽的原本攻击力数值（负数按0处理），并登记操作信息。
function c40101111.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rec=e:GetHandler():GetBattleTarget():GetAttack()
	if rec<0 then rec=0 end
	-- 将当前连锁处理的对象玩家设为要回复LP的玩家tp。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设为回复量rec。
	Duel.SetTargetParam(rec)
	-- 登记当前连锁的操作信息：这是一个回复效果，目标玩家为tp，预计回复数值为rec，供其他卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 回复效果的执行函数：从当前连锁信息中取出对象玩家和回复量，执行LP回复操作。
function c40101111.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前处理的连锁信息中获取对象玩家和对象参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点LP。
	Duel.Recover(p,d,REASON_EFFECT)
end
