--結束の悪魔竜ブラック・デーモンズ・ドラゴン
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡号「红莲魔龙」、①召唤条件限制、②手牌丢卡特召自身二速效果、③特召成功盖放魔陷效果、④战斗阶段开始时削减对方LP并上升攻击力效果
function s.initial_effect(c)
	-- 注册关联卡号列表：包含卡号33599853（红莲魔龙）
	aux.AddCodeList(c,33599853)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：双方回合，从手牌丢弃1张速攻魔法卡或仪式魔法卡才能发动。这张卡从手牌守备表示特殊召唤。
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
	-- ②：这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张有「红莲魔龙」的卡名记述的魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：战斗阶段开始时才能发动。对方失去800基本分，这张卡的攻击力上升800。
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
-- Cost丢弃卡片过滤条件：速攻魔法卡或仪式魔法卡
function s.cfilter(c)
	return (c:IsType(TYPE_QUICKPLAY) or c:IsAllTypes(TYPE_SPELL+TYPE_RITUAL)) and c:IsDiscardable()
end
-- ①效果发动Cost：从手牌丢弃1张速攻魔法卡或仪式魔法卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌中是否存在可丢弃的速攻魔法卡或仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌丢弃1张满足条件的魔法卡
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果发动准备：检查怪兽区格子与召唤条件，设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE) end
	-- 向对方提示选中的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：将此卡表侧守备表示特殊召唤并完成正规召唤手续
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡表侧守备表示特殊召唤（无视召唤条件），成功特召后完成正规召唤手续
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)>0 then
		c:CompleteProcedure()
	end
end
-- 卡组/墓地盖放卡片过滤条件：记述「红莲魔龙」的魔法·陷阱卡且可盖放
function s.setfilter(c)
	-- 检查卡片是否记述卡号33599853（红莲魔龙）、为魔陷卡且能放置到场上
	return aux.IsCodeListed(c,33599853) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动准备：检查卡组/墓地是否存在满足盖放条件的魔陷卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组或墓地是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ②效果处理：从卡组或墓地选择1张记述「红莲魔龙」的魔陷卡在场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地（受王谷影响）选择1张满足条件的魔陷卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的魔法·陷阱卡在场上盖放
		Duel.SSet(tp,tc)
	end
end
-- ③效果发动准备：向对方显示效果发动提示
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示选中的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果处理：对方扣减800LP，并提升自身800攻击力
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方失去800点基本分（LP）
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
