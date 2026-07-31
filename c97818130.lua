--結束の悪魔竜ブラック・デーモンズ・ドラゴン
local s,id,o=GetID()
-- 定义一个函数，用于初始化卡片的效果。
function s.initial_effect(c)
	-- 将这张卡的代码添加到代码列表中，表示这张卡与其他卡存在关联。
	aux.AddCodeList(c,33599853)
	c:EnableReviveLimit()
	-- 设置该卡的复活限制，防止无限复活。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 创建并注册一个效果，用于设定特殊召唤条件。这个效果是单次性的、不可被无效化的，并且影响特殊召唤的触发。
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
	-- 创建并注册一个效果，实现特殊召唤。效果描述来自字符串ID 0，类别为特殊召唤，类型为快速启动型，在任意时机可以发动，作用范围是手牌，提示时机为怪兽正面上场或结束阶段，限制每回合只能发动一次，需要支付费用（s.spcost），指定目标（s.sptg），并执行操作（s.spop）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 创建并注册一个效果，实现盖放魔陷卡。效果描述来自字符串ID 1，类别为盖放，类型为单次触发型，在特殊召唤成功时触发，延迟生效，指定目标（s.settg），并执行操作（s.setop）。
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
-- 创建并注册一个效果，改变攻击力。效果描述来自字符串ID 2，类别为改变攻击力，类型为场上诱发型，在战斗阶段开始时触发，作用范围是怪兽区域，限制每回合只能发动一次，指定目标（s.atktg），并执行操作（s.atkop）。
function s.cfilter(c)
	return (c:IsType(TYPE_QUICKPLAY) or c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL)) and c:IsDiscardable()
end
-- 定义一个过滤函数，用于筛选可以丢弃的卡片。该函数检查卡片是否为速攻魔法或仪式魔法，以及是否可以被丢弃。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 定义一个函数，作为特殊召唤效果的费用支付部分。如果检查标志为0，则检查手牌中是否存在满足s.cfilter过滤条件的卡片。否则，让玩家丢弃1-1张满足s.cfilter过滤条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 检查手牌中是否有符合条件的卡片。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 让玩家丢弃满足条件的卡片作为费用。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 定义一个函数，作为特殊召唤效果的目标选择部分。获取效果的处理者（卡片），如果检查标志为0，则检查对方怪兽区域是否为空，以及该卡是否可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE) end
	-- 提示玩家对方选择了什么。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前处理的连锁的操作信息，表示这是一个特殊召唤的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义一个函数，作为特殊召唤效果的执行部分。获取效果的处理者（卡片），如果该卡与连锁有关并且成功特殊召唤，则完成程序。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否在连锁中以及特殊召唤是否成功。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)>0 then
		c:CompleteProcedure()
	end
end
-- 定义一个过滤函数，用于筛选可以盖放的卡片。该函数检查卡片的代码是否在代码列表中（aux.IsCodeListed），类型是否为魔法或陷阱，以及是否可以被盖放。
function s.setfilter(c)
	-- 判断卡片是否是黑恶魔龙关联卡、魔法/陷阱卡且可盖放。
	return aux.IsCodeListed(c,33599853) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 定义一个函数，作为盖放效果的目标选择部分。如果检查标志为0，则检查牌组或墓地中是否存在满足s.setfilter过滤条件的卡片。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查牌组或墓地中是否有符合条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 定义一个函数，作为盖放效果的执行部分。提示玩家选择要盖放的卡片，然后让玩家从牌组或墓地中选择一张满足s.setfilter过滤条件的卡片并将其盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择符合条件的卡片进行盖放。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行盖放操作。
		Duel.SSet(tp,tc)
	end
end
-- 定义一个函数，作为改变攻击力效果的目标选择部分。如果检查标志为0，则返回true。提示对方玩家该效果的描述。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 定义一个函数，作为改变攻击力效果的执行部分。减少对方场上怪兽的生命值800点。获取效果的处理者（卡片），如果该卡与连锁有关并且正面显示，则创建一个效果来更新攻击力。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 减少对方玩家的生命值。
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)-800)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 创建并注册一个单次性的、不可被无效化的效果，用于改变攻击力。该效果在事件发生时重置，并将攻击力增加800点。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	end
end
