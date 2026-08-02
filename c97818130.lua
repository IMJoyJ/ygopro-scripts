--結束の悪魔竜ブラック・デーモンズ・ドラゴン
local s,id,o=GetID()
-- 注册卡片的基本属性和所有效果。
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名「真红眼黑龙」。
	aux.AddCodeList(c,33599853)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 丢弃1张速攻魔法或包含仪式魔法的魔法卡才能发动；这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功的场合才能发动。从卡组·墓地选1张记述有「真红眼黑龙」卡名的魔法·陷阱卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 战斗阶段开始时才能发动。对方失去800基本分，这张卡的攻击力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 用于筛选可以作为代价丢弃的速攻魔法卡或魔法/仪式卡的过滤函数。
function s.cfilter(c)
	return (c:IsType(TYPE_QUICKPLAY) or c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL)) and c:IsDiscardable()
end
-- 特殊召唤效果的发动代价处理。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查手卡中是否存在可以作为代价丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选1张满足条件的卡丢弃作为发动代价。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤效果的目标选择和操作信息设置。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动前检查自己场上是否有可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE) end
	-- 向对方提示选择了发动这个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 告知系统该效果包含特殊召唤这张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的具体处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否还在手卡，并尝试将其表侧守备表示特殊召唤。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)>0 then
		c:CompleteProcedure()
	end
end
-- 用于筛选记述有「真红眼黑龙」卡名的魔法·陷阱卡的过滤函数。
function s.setfilter(c)
	-- 检查卡片文本是否记述了指定卡名、是否是魔法·陷阱卡以及是否可以盖放。
	return aux.IsCodeListed(c,33599853) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放魔法·陷阱卡效果的发动前检查。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在满足条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 盖放魔法·陷阱卡效果的具体处理。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组或墓地中选择1张满足条件且不受王家长眠之谷影响的卡片。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片盖放到自己场上。
		Duel.SSet(tp,tc)
	end
end
-- 改变攻击力效果的发动前检查。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示选择了发动这个改变攻击力的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 改变攻击力效果的具体处理。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方失去800基本分。
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)-800)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 这张卡的攻击力上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	end
end
