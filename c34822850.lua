--煉獄の氾爛
-- 效果：
-- ①：自己准备阶段才能发动。在自己场上把1只「狱火机衍生物」（恶魔族·炎·1星·攻/守0）特殊召唤。
-- ②：「狱火机」怪兽用自身的方法特殊召唤的场合，从自己场上也能把「狱火机」怪兽除外。
-- ③：对方怪兽不能选择在自己场上的「狱火机」怪兽之内除等级最高的怪兽以外的「狱火机」怪兽作为攻击对象，对方不能以此类作为效果的对象。
function c34822850.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段才能发动。在自己场上把1只「狱火机衍生物」（恶魔族·炎·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c34822850.spcon)
	e2:SetTarget(c34822850.sptg)
	e2:SetOperation(c34822850.spop)
	c:RegisterEffect(e2)
	-- ②：「狱火机」怪兽用自身的方法特殊召唤的场合，从自己场上也能把「狱火机」怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
	e3:SetTarget(c34822850.efftg)
	e3:SetCode(34822850)
	c:RegisterEffect(e3)
	-- ③：对方怪兽不能选择在自己场上的「狱火机」怪兽之内等级最高的怪兽以外的「狱火机」怪兽作为攻击对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c34822850.atlimit)
	c:RegisterEffect(e4)
	-- 对方不能以该怪兽以外的「狱火机」怪兽作为效果的对象
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c34822850.tglimit)
	-- 设置效果保护为无法被对方的效果选择为对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 衍生物特殊召唤效果的发动条件判定（自己回合）
function c34822850.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 衍生物特殊召唤效果的发动检测
function c34822850.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否具有特殊召唤「狱火机衍生物」的能力
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) end
	-- 设置操作信息为生成衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 衍生物特殊召唤效果的操作执行
function c34822850.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e)
		-- 检查怪兽区域是否没有空位
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否无法特殊召唤「狱火机衍生物」
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) then return end
	-- 创建「狱火机衍生物」的卡片数据
	local token=Duel.CreateToken(tp,34822851)
	-- 特殊召唤选中的衍生物
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡或墓地中的「狱火机」怪兽
function c34822850.efftg(e,c)
	return c:IsSetCard(0xbb)
end
-- 过滤场上符合条件的且等级高于目标怪兽的「狱火机」怪兽
function c34822850.filter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xbb) and c:GetLevel()>lv
end
-- 攻击对象选择限制的判定
function c34822850.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xbb)
		-- 检查是否存在等级更高的「狱火机」怪兽，限制不能选择其为攻击对象
		and (not c:IsHasLevel() or Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel()))
end
-- 效果对象选择限制的判定
function c34822850.tglimit(e,c)
	return c:IsSetCard(0xbb)
		-- 检查是否存在等级更高的「狱火机」怪兽，限制不能选择其为效果对象
		and Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel())
end
