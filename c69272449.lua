--M∀LICE＜P＞White Rabbit
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。同名卡不在自己墓地存在的1张「码丽丝」陷阱卡从卡组到自己场上盖放。
-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（召唤·特殊召唤时从卡组盖放陷阱）、②效果（所连接区的码丽丝连接怪兽战斗伤害为0）和③效果（被除外时支付300生命值特殊召唤并限制额外卡组特召）。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。同名卡不在自己墓地存在的1张「码丽丝」陷阱卡从卡组到自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.damfilter)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e4)
	-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+o)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
-- 过滤卡组中满足条件的「码丽丝」陷阱卡：该卡可以盖放，且同名卡不在自己墓地存在。
function s.setfilter(c,tp)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
		-- 检查自己墓地是否存在与该卡同名的卡。
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- ①效果的发动准备与可行性检查（检查卡组中是否存在可盖放的符合条件的卡）。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「码丽丝」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ①效果的处理：从卡组选择1张满足条件的「码丽丝」陷阱卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「码丽丝」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		-- 将选中的卡片在自己场上盖放。
		Duel.SSet(tp,g)
	end
end
-- 过滤满足条件的怪兽：表侧表示的「码丽丝」连接怪兽，且其所连接区包含这张卡（且这张卡未被战斗破坏）。
function s.damfilter(e,c)
	local lg=c:GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
		and lg and lg:IsContains(e:GetHandler()) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ③效果的Cost处理：检查并支付300基本分。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付300基本分。
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 扣除玩家300基本分。
	Duel.PayLPCost(tp,300)
end
-- ③效果的发动准备与可行性检查（检查怪兽区域是否有空位，以及自身是否可以特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理：将自身特殊召唤，并适用“这个回合自己不是连接怪兽不能从额外卡组特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制玩家从额外卡组特殊召唤非连接怪兽的全局效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特召的过滤函数：阻止从额外卡组特殊召唤非连接怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
