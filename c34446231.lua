--インフェルノイド・フラッド
-- 效果：
-- 包含「狱火机」怪兽的怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方把怪兽特殊召唤之际，把自己场上1只怪兽解放才能发动。那次特殊召唤无效，那些怪兽除外。
-- ②：从自己墓地有卡被除外的场合才能发动。场上1张卡除外。
-- ③：连接召唤的这张卡被对方破坏的场合才能发动。从卡组把1只「狱火机」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用连接召唤手续并注册三个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤所需素材为2~4只包含「狱火机」的怪兽
	aux.AddLinkProcedure(c,nil,2,4,s.lcheck)
	-- ①：对方把怪兽特殊召唤之际，把自己场上1只怪兽解放才能发动。那次特殊召唤无效，那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤无效"
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地有卡被除外的场合才能发动。场上1张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ③：连接召唤的这张卡被对方破坏的场合才能发动。从卡组把1只「狱火机」怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接召唤素材检查函数，确保至少有一只包含「狱火机」的怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xbb)
end
-- 效果①的发动条件，判断是否为对方特殊召唤且当前无连锁处理
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方特殊召唤且当前无连锁处理
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 解放所需卡牌的过滤函数，判断是否为怪兽类型
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- 效果①的发动费用，检查是否能解放1只怪兽并选择解放
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能解放1只怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动目标设定，设置无效召唤和除外操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能除外卡牌
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 设置无效召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- 效果①的发动处理，使召唤无效并除外相关怪兽
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效
	Duel.NegateSummon(eg)
	-- 除外相关怪兽
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
-- 墓地除外卡牌的过滤函数，判断是否为从墓地被除外的卡
function s.rmfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果②的发动条件，判断是否有从墓地被除外的卡
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmfilter,1,nil,tp)
end
-- 效果②的发动目标设定，选择场上1张卡除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的发动处理，选择并除外场上1张卡
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张可除外的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #sg>0 then
		-- 显示选中卡牌的动画效果
		Duel.HintSelection(sg)
		-- 执行除外操作
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的发动条件，判断是否为连接召唤被对方破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp
end
-- 从卡组特殊召唤的过滤函数，判断是否为「狱火机」怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xbb) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果③的发动目标设定，检查是否有可特殊召唤的「狱火机」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「狱火机」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的发动处理，从卡组特殊召唤1只「狱火机」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的「狱火机」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
