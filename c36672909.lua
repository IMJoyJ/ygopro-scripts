--再世律
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有原本攻击力或原本守备力是2500的怪兽存在的场合，以对方场上1张卡为对象才能发动（自己场上有「创世之神 狄特罗诺米安」存在的场合，这个效果的对象可以变成2张）。那张卡除外。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从手卡把1只攻击力或守备力是2500的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，设置两个效果：①除外对方场上卡片；②从墓地特殊召唤2500攻击力或守备力的怪兽
function s.initial_effect(c)
	-- 记录该卡拥有「创世之神 狄特罗诺米安」的卡名代码，用于效果判定
	aux.AddCodeList(c,22812963)
	-- ①：自己场上有原本攻击力或原本守备力是2500的怪兽存在的场合，以对方场上1张卡为对象才能发动（自己场上有「创世之神 狄特罗诺米安」存在的场合，这个效果的对象可以变成2张）。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从手卡把1只攻击力或守备力是2500的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果发动时，检查该卡是否在墓地且未在本回合送去墓地
	e2:SetCondition(aux.exccon)
	-- 效果发动时，将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断场上是否存在攻击力或守备力为2500的怪兽
function s.cfilter(c)
	return c:IsFaceup() and (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500)
end
-- 效果①的发动条件：自己场上存在攻击力或守备力为2500的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在攻击力或守备力为2500的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的目标选择与处理：根据是否拥有「创世之神 狄特罗诺米安」决定可选择对象数量，并设置除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 若自己场上存在「创世之神 狄特罗诺米安」，则效果①可选择2张对方场上的卡
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,22812963) then ct=2 end
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查是否满足效果①的发动条件：对方场上存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1~2张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果①的处理信息：将选中的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的处理：将选中的卡除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中与效果相关的对象
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将对象从场上除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤函数：判断手卡中是否存在攻击力或守备力为2500且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标选择：检查手卡中是否存在满足条件的怪兽并设置特殊召唤信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在攻击力或守备力为2500的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果②的处理信息：特殊召唤1只满足条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理：从手卡选择1只满足条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只攻击力或守备力为2500的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
