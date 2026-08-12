--ダイダラボッチ
-- 效果：
-- 这张卡不能特殊召唤。这张卡可以把1只不死族怪兽解放表侧表示上级召唤。
-- ①：这张卡的攻击力上升自己场上的其他的不死族怪兽数量×200。
-- ②：这张卡在墓地存在，自己墓地有「大太郎法师」以外的不死族怪兽2只以上存在的场合，自己主要阶段1开始时，丢弃1张手卡才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含不能特殊召唤、特殊上级召唤、攻击力上升、墓地回收效果
function s.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只不死族怪兽解放表侧表示上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"把1只不死族怪兽解放表侧表示上级召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.otcon)
	e2:SetOperation(s.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己场上的其他的不死族怪兽数量×200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在，自己墓地有「大太郎法师」以外的不死族怪兽2只以上存在的场合，自己主要阶段1开始时，丢弃1张手卡才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.thcon)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤用于特殊上级召唤解放的不死族怪兽（自己场上的，或者对方场上表侧表示的）
function s.otfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊上级召唤的条件判定函数
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足解放条件的不死族怪兽
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定此卡等级在7星以上、最少祭品数不大于1，且场上存在1只可解放的怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 特殊上级召唤的解放操作函数
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有满足解放条件的不死族怪兽
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 玩家选择1只用于上级召唤解放的不死族怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤自己场上表侧表示的不死族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 计算攻击力上升值的函数
function s.atkval(e)
	-- 返回自己场上除自身以外的不死族怪兽数量乘以200的数值
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())*200
end
-- 过滤自己墓地中「大太郎法师」以外的不死族怪兽
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(id)
end
-- 墓地回收效果的发动条件判定函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己主要阶段1的开始时（尚未进行任何行动）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 判定自己墓地是否存在2只以上「大太郎法师」以外的不死族怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 墓地回收效果的发动代价（Cost）处理函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 墓地回收效果的目标（Target）处理函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置效果处理信息为：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 墓地回收效果的效果处理（Operation）函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其加入手卡
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
