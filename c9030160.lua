--常闇の契約書
-- 效果：
-- ①：自己的灵摆区域有2张「DD」卡存在的场合，对方不能把场上的怪兽作为魔法·陷阱卡的效果的对象，不能作为上级召唤的解放，也不能作为融合·同调·超量召唤的素材。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c9030160.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆区域有2张「DD」卡存在的场合，对方不能把场上的怪兽作为魔法·陷阱卡的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c9030160.condition)
	e2:SetValue(c9030160.evalue)
	c:RegisterEffect(e2)
	-- ①：自己的灵摆区域有2张「DD」卡存在的场合，对方不能把场上的怪兽...不能作为上级召唤的解放
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c9030160.condition)
	e3:SetValue(c9030160.sumlimit)
	c:RegisterEffect(e3)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e5:SetValue(c9030160.fuslimit)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e7)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(9030160,0))
	e8:SetCategory(CATEGORY_DAMAGE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(c9030160.damcon)
	e8:SetTarget(c9030160.damtg)
	e8:SetOperation(c9030160.damop)
	c:RegisterEffect(e8)
end
-- 效果①的条件函数：检查自己的灵摆区域是否有2张「DD」卡
function c9030160.condition(e)
	-- 检查自己的灵摆区域是否存在至少2张「DD」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,2,nil,0xaf)
end
-- 限制对方不能将场上的怪兽作为上级召唤的解放
function c9030160.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
-- 限制对方不能将场上的怪兽作为融合召唤的素材
function c9030160.fuslimit(e,c,sumtype)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end
-- 限制对方不能将场上的怪兽作为魔法·陷阱卡的效果的对象
function c9030160.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
-- 效果②的发动条件：当前回合是自己的回合
function c9030160.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的发动准备：设置伤害目标为自己，伤害数值为1000
function c9030160.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置受到伤害的玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置伤害数值为1000
	Duel.SetTargetParam(1000)
	-- 声明该效果包含伤害分类，目标为自己，数值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 效果②的效果处理：给与自己1000点伤害
function c9030160.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的伤害目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
