--M∀LICE＜P＞Cheshire Cat
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡选1张「码丽丝」卡除外。那之后，自己可以抽2张。
-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽战斗破坏的怪兽不去墓地而除外。
-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡选1张「码丽丝」卡除外。那之后，自己可以抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外并抽卡"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽战斗破坏的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.immcon)
	e2:SetTarget(s.immtg)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可除外的「码丽丝」卡的条件函数。
function s.rmfilter(c)
	return c:IsSetCard(0x1bf) and c:IsAbleToRemove()
end
-- 效果①的发动条件检查与操作信息设置函数。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可除外的「码丽丝」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理中的操作信息为：从手牌除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
-- 效果①的实际效果处理函数（除外并抽卡）。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1张满足条件的「码丽丝」卡。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil)
	local rc=g:GetFirst()
	-- 检查是否成功将选中的卡片表侧表示除外。
	if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)~=0 and rc:IsLocation(LOCATION_REMOVED)
		-- 检查玩家当前是否可以抽2张卡。
		and Duel.IsPlayerCanDraw(tp,2)
		-- 询问玩家是否选择进行抽卡。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续的抽卡处理与除外处理不视为同时进行。
		Duel.BreakEffect()
		-- 玩家因效果抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- 效果②的适用条件：自身未被战斗破坏。
function s.immcon(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的适用对象过滤：指向此卡的「码丽丝」连接怪兽。
function s.immtg(e,c)
	local lg=c:GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
		and lg and lg:IsContains(e:GetHandler())
end
-- 效果③的发动代价处理函数（支付300基本分）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付300基本分。
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 扣除玩家300基本分。
	Duel.PayLPCost(tp,300)
end
-- 效果③的发动条件与特殊召唤目标设置。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位，且此卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的实际效果处理函数（特殊召唤自身并施加额外卡组特召限制）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡表侧表示特殊召唤到自己的怪兽区域。
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
	-- 注册全局效果，限制玩家从额外卡组特殊召唤非连接怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特召的过滤函数：不能从额外卡组特殊召唤非连接怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
