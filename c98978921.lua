--リンク・スパイダー
-- 效果：
-- 通常怪兽1只
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只4星以下的通常怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c98978921.initial_effect(c)
	-- 设置连接召唤手续：需要1只通常怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_NORMAL),1,1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只4星以下的通常怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98978921,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c98978921.target)
	e1:SetOperation(c98978921.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选手卡中等级4以下、可以特殊召唤到此卡连接区的通常怪兽
function c98978921.filter(c,e,tp,zone)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动准备与合法性检测，检查是否存在可特殊召唤的怪兽并声明特殊召唤的操作信息
function c98978921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 检查此卡指向的区域是否可用，且手卡中是否存在至少1只满足条件的怪兽
		return zone~=0 and Duel.IsExistingMatchingCard(c98978921.filter,tp,LOCATION_HAND,0,1,nil,e,tp,zone)
	end
	-- 设置连锁操作信息，声明该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理，从手卡选择1只满足条件的通常怪兽特殊召唤到此卡指向的区域
function c98978921.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if zone==0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c98978921.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到此卡指向的区域
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
