--アルティメットサイキッカー
-- 效果：
-- 念动力族同调怪兽＋念动力族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡只要在怪兽区域存在，不会被效果破坏。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c40101111.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的同调怪兽和念动力族怪兽各1只为融合素材
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
-- 判断特殊召唤方式是否为融合召唤，若为融合召唤则允许从额外卡组特殊召唤
function c40101111.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 过滤满足同调类型且为念动力族的怪兽
function c40101111.ffilter(c)
	return c:IsFusionType(TYPE_SYNCHRO) and c:IsRace(RACE_PSYCHO)
end
-- 判断战斗中攻击的怪兽是否在墓地且为怪兽卡
function c40101111.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 设置连锁处理时的回复参数
function c40101111.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rec=e:GetHandler():GetBattleTarget():GetAttack()
	if rec<0 then rec=0 end
	-- 设置连锁处理时的回复对象玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理时的回复数值
	Duel.SetTargetParam(rec)
	-- 设置连锁操作信息，指定回复效果的处理对象和数量
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 执行回复效果，使玩家回复指定数值的生命值
function c40101111.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时的回复对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使指定玩家回复指定数值的生命值，原因来自效果
	Duel.Recover(p,d,REASON_EFFECT)
end
