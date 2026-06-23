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
	-- ③：对方怪兽不能选择在自己场上的「狱火机」怪兽之内除等级最高的怪兽以外的「狱火机」怪兽作为攻击对象，
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
	-- 设置效果值为aux.tgoval，用于判断效果来源是否为对方玩家
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 定义准备阶段特殊召唤衍生物的发动条件函数，检查是否为自己的回合
function c34822850.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家并检查是否为自己（满足"自己准备阶段"的发动条件）
	return Duel.GetTurnPlayer()==tp
end
-- 定义准备阶段特殊召唤衍生物的目标检测函数，检查是否可以特殊召唤衍生物
function c34822850.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格（区域数量大于0）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤指定的狱火机衍生物（代码34822851，系列0xbb，种族恶魔，属性炎，等级1，攻守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) end
	-- 设置连锁操作信息，声明要处理的效果分类为生成衍生物（CATEGORY_TOKEN），数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息，声明要处理的效果分类为特殊召唤（CATEGORY_SPECIAL_SUMMON），数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义准备阶段特殊召唤衍生物的效果处理函数，执行衍生物的特殊召唤
function c34822850.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e)
		-- 再次检查主要怪兽区是否有可用空格（防止发动后格子被占用导致无法处理）
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 再次检查是否可以特殊召唤指定的衍生物（防止发动后条件变化导致无法处理），如果不满足则直接返回
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) then return end
	-- 在自己场上创建1只狱火机衍生物（卡片代码34822851）
	local token=Duel.CreateToken(tp,34822851)
	-- 将创建的衍生物以表侧表示特殊召唤到自己场上，不检查召唤条件、不限制苏生限制
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义效果②的目标过滤函数，检查卡片是否为「狱火机」系列（系列代码0xbb）
function c34822850.efftg(e,c)
	return c:IsSetCard(0xbb)
end
-- 定义等级过滤函数，检查卡片是否为表侧表示的狱火机怪兽且等级大于指定值
function c34822850.filter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xbb) and c:GetLevel()>lv
end
-- 定义攻击限制值函数，检查目标是否为除等级最高的狱火机怪兽以外的狱火机怪兽（满足条件则不能被选择为攻击对象）
function c34822850.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xbb)
		-- 检查该怪兽是否没有等级，或者自己场上是否存在等级更高的狱火机怪兽（存在更高等级则此怪兽不能被攻击）
		and (not c:IsHasLevel() or Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel()))
end
-- 定义效果对象限制值函数，检查目标是否为除等级最高的狱火机怪兽以外的狱火机怪兽（满足条件则不能被选择为效果对象）
function c34822850.tglimit(e,c)
	return c:IsSetCard(0xbb)
		-- 检查自己场上是否存在等级比此怪兽更高的狱火机怪兽（存在更高等级则此怪兽不能成为效果对象）
		and Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel())
end
