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
	-- ③：对方怪兽不能选择在自己场上的「狱火机」怪兽之内除等级最高的怪兽以外的「狱火机」怪兽作为攻击对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c34822850.atlimit)
	c:RegisterEffect(e4)
	-- 对方不能以此类作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c34822850.tglimit)
	-- 保护效果：不会成为对方卡片效果的对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 判断是否是自己的准备阶段
function c34822850.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是自己
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤狱火机衍生物的目标选择与操作信息设置
function c34822850.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能特殊召唤狱火机衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) end
	-- 设置操作信息：生成Token，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：特殊召唤，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的执行：特殊召唤「狱火机衍生物」
function c34822850.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e)
		-- 检查自己怪兽区是否有空位
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 确认是否能够将狱火机衍生物特殊召唤
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) then return end
	-- 创建「狱火机衍生物」的卡片数据
	local token=Duel.CreateToken(tp,34822851)
	-- 将「狱火机衍生物」特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：是否属于「狱火机」系列
function c34822850.efftg(e,c)
	return c:IsSetCard(0xbb)
end
-- 过滤条件：场上表侧表示、等级更高的「狱火机」怪兽
function c34822850.filter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xbb) and c:GetLevel()>lv
end
-- 对方攻击目标限制：等级最高的怪兽以外的「狱火机」怪兽不能被选择为攻击对象
function c34822850.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xbb)
		-- 确认是否存在比自身等级更高的「狱火机」怪兽
		and (not c:IsHasLevel() or Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel()))
end
-- 对方效果对象限制：等级最高的怪兽以外的「狱火机」怪兽不能被选择为效果对象
function c34822850.tglimit(e,c)
	return c:IsSetCard(0xbb)
		-- 确认场上是否存在等级比自身更高的「狱火机」怪兽
		and Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel())
end
