--フレムベル・デスガンナー
-- 效果：
-- 这张卡不能被特殊召唤。只能通过解放自己场上1只名字带有「炎狱」的怪兽来召唤。1回合1次，可以把自己墓地中存在的1只守备力200的怪兽从游戏中除外，给与对方玩家那只怪兽攻击力数值的伤害。
function c40189917.initial_effect(c)
	-- 这张卡不能被特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为 false，使这张卡不能被任何方式特殊召唤。
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
-- 过滤函数：筛选满足名字带有「炎狱」且（控制者为自己或表侧表示）的怪兽，作为潜在的解放素材。
function c40189917.mfilter(c,tp)
	return c:IsSetCard(0x2c) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤规则限制的召唤条件判定：若调用参数 c 为空则放行（用于规则询问）；否则获取控制者 tp，筛选可用的炎狱怪兽，并确认所需解放数不超过1且存在1只可解放的怪兽。
function c40189917.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方怪兽区域中所有满足 mfilter 条件的「炎狱」怪兽，作为可供解放的候选集合。
	local mg=Duel.GetMatchingGroup(c40189917.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断召唤所需的祭品数量不超过 1，且候选集合中存在可用的 1 只祭品。
	return minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤执行操作：从候选的「炎狱」怪兽中选择 1 只进行解放，完成上级召唤手续。
function c40189917.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方怪兽区域中所有满足 mfilter 条件的「炎狱」怪兽，作为选择祭品的候选组。
	local mg=Duel.GetMatchingGroup(c40189917.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家 tp 从候选组中选择 1 只怪兽作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品解放，解放原因为上级召唤的素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：选择墓地中守备力为 200 且可以作为除外代价的怪兽。
function c40189917.cfilter(c)
	return c:IsDefense(200) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：先检查墓地是否存在符合条件的怪兽；若可以支付，则选择 1 只除外，并把那只怪兽的攻击力记录到效果的 label 中，作为伤害数值。
function c40189917.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：返回墓地是否存在至少 1 张满足 cfilter 的怪兽，以决定代价能否支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c40189917.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要除外的卡”的提示，引导玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择 1 张守备力 200 且可除外的怪兽。
	local g=Duel.SelectMatchingCard(tp,c40189917.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽以表侧表示除外，作为发动效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- 效果发动时的目标设定：将对象玩家设为对方，伤害值设为已记录的怪兽攻击力，并设置伤害类操作信息。
function c40189917.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数设置为 e 标签中记录的怪兽攻击力，作为将要造成的伤害数值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息：效果分类为伤害，对象为对方玩家，伤害值为记录的怪兽攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理：从连锁信息中获取对象玩家和伤害数值，然后给对方玩家造成该数值的效果伤害。
function c40189917.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出保存的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家 p 造成 d 点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
