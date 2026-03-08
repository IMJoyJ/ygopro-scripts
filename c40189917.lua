--フレムベル・デスガンナー
-- 效果：
-- 这张卡不能被特殊召唤。只能通过解放自己场上1只名字带有「炎狱」的怪兽来召唤。1回合1次，可以把自己墓地中存在的1只守备力200的怪兽从游戏中除外，给与对方玩家那只怪兽攻击力数值的伤害。
function c40189917.initial_effect(c)
	-- 这张卡不能被特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤（始终返回假值）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 只能通过解放自己场上1只名字带有「炎狱」的怪兽来召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e2:SetCondition(c40189917.sumcon)
	e2:SetOperation(c40189917.sumop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把自己墓地中存在的1只守备力200的怪兽从游戏中除外，给与对方玩家那只怪兽攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40189917,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c40189917.damcost)
	e3:SetTarget(c40189917.damtg)
	e3:SetOperation(c40189917.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上或自己控制的「炎狱」怪兽。
function c40189917.mfilter(c,tp)
	return c:IsSetCard(0x2c) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤条件函数，检查是否满足解放1只「炎狱」怪兽的召唤条件。
function c40189917.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上符合条件的「炎狱」怪兽组。
	local mg=Duel.GetMatchingGroup(c40189917.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否能通过祭品召唤该卡。
	return minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 召唤操作函数，选择并解放1只「炎狱」怪兽完成召唤。
function c40189917.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上符合条件的「炎狱」怪兽组。
	local mg=Duel.GetMatchingGroup(c40189917.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于召唤的祭品怪兽。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品怪兽解放。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数，用于筛选墓地中守备力为200且可作为费用除外的怪兽。
function c40189917.cfilter(c)
	return c:IsDefense(200) and c:IsAbleToRemoveAsCost()
end
-- 伤害效果的费用支付函数，选择并除外1只守备力200的怪兽。
function c40189917.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外1只守备力200怪兽的费用条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c40189917.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只守备力200的怪兽从墓地除外。
	local g=Duel.SelectMatchingCard(tp,c40189917.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- 伤害效果的目标设定函数，设置目标玩家和伤害值。
function c40189917.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为除外怪兽的攻击力。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息，准备造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 伤害效果的处理函数，对目标玩家造成伤害。
function c40189917.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
