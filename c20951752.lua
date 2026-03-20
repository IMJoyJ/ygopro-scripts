--裁きを下す者－ボルテニス
-- 效果：
-- 自己的反击陷阱发动成功的场合，把自己场上全部怪兽作祭品可以特殊召唤。这个方法特殊召唤成功的场合，可以把最多有作祭品的天使族怪兽的数量的对方场上的卡破坏。
function c20951752.initial_effect(c)
	-- 自己的反击陷阱发动成功的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(c20951752.chop1)
	c:RegisterEffect(e1)
	-- 自己的反击陷阱发动成功的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c20951752.chop2)
	c:RegisterEffect(e2)
	-- 把自己场上全部怪兽作祭品可以特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20951752,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c20951752.sumcon)
	e3:SetCost(c20951752.sumcost)
	e3:SetTarget(c20951752.sumtg)
	e3:SetOperation(c20951752.sumop)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
	-- 这个方法特殊召唤成功的场合，可以把最多有作祭品的天使族怪兽的数量的对方场上的卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20951752,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c20951752.descon)
	e4:SetTarget(c20951752.destg)
	e4:SetOperation(c20951752.desop)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end
-- 在连锁开始时，将特殊召唤效果的触发标志重置为0
function c20951752.chop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
-- 在连锁解决后，检查是否是对手的反击陷阱发动成功，如果是则设置触发标志为1
function c20951752.chop2(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) then return end
	e:GetLabelObject():SetLabel(1)
end
-- 检查触发标志是否为1，以决定是否满足特殊召唤条件
function c20951752.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
-- 支付特殊召唤的代价：解放自己场上全部怪兽，并计数其中天使族怪兽的数量
function c20951752.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 获取玩家场上所有可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp)
	local ct=g:FilterCount(Card.IsRace,nil,RACE_FAIRY)
	-- 处理额外解放效果，如暗影敌托邦的代替解放
	aux.UseExtraReleaseCount(g,tp)
	-- 解放怪兽组作为代价
	Duel.Release(g,REASON_COST)
	e:GetLabelObject():SetLabel(ct)
end
-- 检查当前卡片是否可特殊召唤，并设置特殊召唤的操作信息
function c20951752.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤当前卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 如果卡片与效果相关，则进行特殊召唤
function c20951752.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以自身效果方式特殊召唤卡片到玩家场上，表侧表示
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查特殊召唤类型是否为自身效果的特殊召唤
function c20951752.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 检查对方场上是否存在卡且天使族计数大于0，并设置破坏效果的操作信息
function c20951752.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡且天使族计数大于0
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) and e:GetLabel()>0 end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息为破坏，指定对方场上所有卡为可能目标，预计破坏数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 获取对方场上的卡，提示玩家选择最多天使族数量的卡进行破坏
function c20951752.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在破坏效果处理中，获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,1,e:GetLabel(),nil)
	-- 显示被选卡片的动画效果
	Duel.HintSelection(dg)
	-- 以效果原因破坏选择的卡片
	Duel.Destroy(dg,REASON_EFFECT)
end
