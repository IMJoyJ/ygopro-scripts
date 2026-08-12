--黄昏の忍者－ジョウゲン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己的「忍者」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽效果】
-- ①：把手卡1张「忍法」卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c79441381.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「忍者」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯穿效果的影响对象为我方场上的「忍者」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2b))
	c:RegisterEffect(e1)
	-- ①：把手卡1张「忍法」卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79441381,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c79441381.spcost)
	e2:SetTarget(c79441381.sptg)
	e2:SetOperation(c79441381.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 过滤手卡中未公开的「忍法」卡
function c79441381.costfilter(c)
	return c:IsSetCard(0x61) and not c:IsPublic()
end
-- 特殊召唤效果的发动代价：展示手卡1张「忍法」卡
function c79441381.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可用于展示的「忍法」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79441381.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1张满足条件的「忍法」卡
	local g=Duel.SelectMatchingCard(tp,c79441381.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选择的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 特殊召唤效果的发动检测
function c79441381.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理
function c79441381.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到我方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
