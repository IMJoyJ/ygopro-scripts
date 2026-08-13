--速炎星－タイヒョウ
-- 效果：
-- 这张卡召唤·特殊召唤成功的回合的主要阶段时，把自己场上1只名字带有「炎星」的怪兽解放才能发动。从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。「速炎星-戴豹」的效果1回合只能使用1次。
function c39699564.initial_effect(c)
	-- 把自己场上1只名字带有「炎星」的怪兽解放才能发动。从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。「速炎星-戴豹」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39699564,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,39699564)
	e1:SetCondition(c39699564.setcon)
	e1:SetCost(c39699564.setcost)
	e1:SetTarget(c39699564.settg)
	e1:SetOperation(c39699564.setop)
	c:RegisterEffect(e1)
	-- 这张卡召唤·特殊召唤成功的回合的主要阶段时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c39699564.sumop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 发动条件判定：检查此卡本回合是否被召唤或特殊召唤成功过（通过flag标记实现）。
function c39699564.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(39699564)>0
end
-- 发动代价：解放自己场上1只名字带有「炎星」的怪兽（作为cost，不取对象）。
function c39699564.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认玩家场上是否存在至少1只可解放的名字带有「炎星」的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x79) end
	-- 选择要解放的1只名字带有「炎星」的怪兽。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x79)
	-- 解放所选择的怪兽，作为效果发动代价。
	Duel.Release(g,REASON_COST)
end
-- 筛选条件：卡组中名字带有「炎舞」的、可以盖放到魔陷区的魔法·陷阱卡。
function c39699564.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 目标设定：确认卡组中存在至少1张满足筛选条件的「炎舞」魔法·陷阱卡；不取对象，只作发动可行性判定。
function c39699564.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：卡组中是否存在符合条件的「炎舞」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c39699564.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选择1张符合条件的「炎舞」魔法·陷阱卡，盖放到自己场上。
function c39699564.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张符合条件的「炎舞」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c39699564.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片盖放到自己场上（魔法陷阱区）。
		Duel.SSet(tp,g)
	end
end
-- 召唤或特殊召唤成功时，为此卡注册一个本回合已召唤成功的标记（结束阶段重置），用于满足起动效果的发动条件。
function c39699564.sumop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(39699564,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
