--D-HERO ドリルガイ
-- 效果：
-- 「命运英雄 钻头人」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。把持有这张卡的攻击力以下的攻击力的1只「命运英雄」怪兽从手卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c91691605.initial_effect(c)
	-- 「命运英雄 钻头人」的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。把持有这张卡的攻击力以下的攻击力的1只「命运英雄」怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91691605,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,91691605)
	e1:SetTarget(c91691605.target)
	e1:SetOperation(c91691605.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 过滤手牌中属于「命运英雄」系列、攻击力在此卡当前攻击力以下且可以特殊召唤的怪兽
function c91691605.filter(c,e,tp,atk)
	return c:IsSetCard(0xc008) and c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数
function c91691605.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只攻击力在此卡攻击力以下的「命运英雄」怪兽
		and Duel.IsExistingMatchingCard(c91691605.filter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler():GetAttack()) end
	-- 设置连锁处理的操作信息，表示此效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的实际处理函数
function c91691605.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local atk=c:GetAttack()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足过滤条件的「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c91691605.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,atk)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
