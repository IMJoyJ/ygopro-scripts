--七皇の冀望郷
local s,id,o=GetID()
-- 初始化卡片效果，注册场地卡通用的发动条件和多个持续效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 当有怪兽从额外卡组特殊召唤成功时，记录该玩家的特殊召唤次数
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.count)
	c:RegisterEffect(e2)
	-- 禁止玩家将来自额外卡组且不是七皇卡组的怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
	-- 起动效果：可以从卡组检索一张七皇族怪兽加入手牌，并丢弃一张手牌
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	-- 诱发必发效果：在结束阶段对双方各造成场上的每只XYZ怪兽400伤害
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_FZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCountLimit(1,id+o)
	e6:SetTarget(s.damtg)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
-- 过滤函数，用于判断是否为非七皇族、从额外卡组召唤的怪兽
function s.cfilter(c,tp)
	return not c:IsSetCard(0x48) and c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 遍历双方玩家，若存在符合条件的特殊召唤，则为该玩家注册标记
function s.count(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.cfilter,1,nil,p) then
			e:GetHandler():RegisterFlagEffect(id+p*100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 限制条件函数，判断是否禁止特定玩家将额外卡组的非七皇族怪兽特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x48)
		and e:GetHandler():GetFlagEffect(id+sump*100)>1
end
-- 过滤函数，用于检索卡组中可加入手牌的七皇族怪兽
function s.thfilter(c)
	return c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息，确定要从卡组检索的卡数量和位置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即场上是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索并加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果的操作，选择卡并送入手牌，然后丢弃一张手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并进入手牌区域
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认对手看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 选择一张可丢弃的手牌
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 将选中的手牌送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤函数，用于判断是否为场上正面表示的XYZ怪兽
function s.damfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置伤害效果的目标信息，计算伤害值并设定影响对象
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上的XYZ怪兽数量并乘以400得到总伤害值
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*400
	-- 设置操作信息，表示将要对双方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 处理伤害效果的操作，分别对双方造成伤害并完成时点
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算场上的XYZ怪兽数量并乘以400得到总伤害值
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*400
	-- 给玩家造成指定数量的伤害
	Duel.Damage(tp,dam,REASON_EFFECT,true)
	-- 给对方玩家造成指定数量的伤害
	Duel.Damage(1-tp,dam,REASON_EFFECT,true)
	-- 触发伤害/回复LP过程的时点完成
	Duel.RDComplete()
end
