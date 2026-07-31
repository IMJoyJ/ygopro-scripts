--七皇の冀望郷
local s,id,o=GetID()
-- 初始化卡片效果，注册场地卡的发动、特殊召唤计数、特殊召唤限制、检索与伤害效果
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
	-- 禁止该玩家从额外卡组特殊召唤非“七皇”怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
	-- 起动效果：可以从卡组检索1只“星圣”怪兽加入手牌，并将手牌1张卡送去墓地
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	-- 诱发效果：结束阶段时，对双方各造成场上的XYZ怪兽数量×400的伤害
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
-- 过滤函数：判断是否为非“七皇”怪兽且从额外卡组召唤成功
function s.cfilter(c,tp)
	return not c:IsSetCard(0x48) and c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 统计特殊召唤次数并记录到标记中，用于限制特殊召唤
function s.count(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.cfilter,1,nil,p) then
			e:GetHandler():RegisterFlagEffect(id+p*100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 特殊召唤限制函数：若该玩家已特殊召唤过非“七皇”怪兽，则不能从额外卡组特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x48)
		and e:GetHandler():GetFlagEffect(id+sump*100)>1
end
-- 检索过滤函数：判断是否为“星圣”怪兽且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动条件检测，检查是否有满足条件的卡在卡组中
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认卡组中存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理流程：选择并加入手牌，确认对方查看，破坏手牌并洗切手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并进入手牌区域
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 选择要丢弃的手牌
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 将选定的手牌送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 伤害计算过滤函数：判断是否为表侧表示的XYZ怪兽
function s.damfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 伤害效果的发动条件检测，计算场上的XYZ怪兽数量并设置伤害值
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上XYZ怪兽数量并乘以400作为伤害值
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*400
	-- 设置操作信息：准备对双方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 伤害效果的处理流程：对双方各造成指定伤害并完成时点触发
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次计算场上XYZ怪兽数量并乘以400作为伤害值
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*400
	-- 对玩家造成指定伤害
	Duel.Damage(tp,dam,REASON_EFFECT,true)
	-- 对对方造成指定伤害
	Duel.Damage(1-tp,dam,REASON_EFFECT,true)
	-- 完成伤害处理的时点触发
	Duel.RDComplete()
end
