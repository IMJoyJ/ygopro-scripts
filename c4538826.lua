--終焉龍 カオス・エンペラー
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：支付1000基本分，以除外的1只自己的龙族怪兽为对象才能发动。这张卡破坏，那只怪兽加入手卡。
-- 【怪兽效果】
-- 这张卡不能通常召唤。「终焉龙 混沌帝」1回合1次在把自己墓地的光属性和暗属性的怪兽各1只除外的场合才能从手卡·额外卡组特殊召唤。
-- ①：1回合1次，把基本分支付一半才能发动。额外怪兽区域以外的自己场上的卡全部送去墓地，选最多有送去墓地的数量的对方场上的卡送去墓地。那之后，给与对方送去对方墓地的数量×300伤害。
-- ②：特殊召唤的表侧表示的这张卡从场上离开的场合回到卡组最下面。
function c4538826.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：支付1000基本分，以除外的1只自己的龙族怪兽为对象才能发动。这张卡破坏，那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4538826,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,4538826)
	e1:SetCost(c4538826.thcost)
	e1:SetTarget(c4538826.thtg)
	e1:SetOperation(c4538826.thop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 「终焉龙 混沌帝」1回合1次在把自己墓地的光属性和暗属性的怪兽各1只除外的场合才能从手卡·额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCountLimit(1,4538827+EFFECT_COUNT_CODE_OATH)
	e3:SetRange(LOCATION_EXTRA+LOCATION_HAND)
	e3:SetCondition(c4538826.spcon)
	e3:SetTarget(c4538826.sptg)
	e3:SetOperation(c4538826.spop)
	c:RegisterEffect(e3)
	-- ①：1回合1次，把基本分支付一半才能发动。额外怪兽区域以外的自己场上的卡全部送去墓地，选最多有送去墓地的数量的对方场上的卡送去墓地。那之后，给与对方送去对方墓地的数量×300伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4538826,1))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c4538826.gycost)
	e4:SetTarget(c4538826.gytg)
	e4:SetOperation(c4538826.gyop)
	c:RegisterEffect(e4)
	-- ②：特殊召唤的表侧表示的这张卡从场上离开的场合回到卡组最下面。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetOperation(c4538826.spreg)
	c:RegisterEffect(e5)
end
-- 支付1000基本分作为此效果的发动费用
function c4538826.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 定义灵摆效果中可选择的目标怪兽的过滤条件：必须是表侧表示、龙族且能加入手牌
function c4538826.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 设置灵摆效果的目标选择逻辑，确保选择的是除外的己方龙族怪兽
function c4538826.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c4538826.thfilter(chkc) end
	-- 检查是否存在满足条件的除外的己方龙族怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c4538826.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的除外的己方龙族怪兽作为目标
	local g=Duel.SelectTarget(tp,c4538826.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将此卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行灵摆效果的操作：破坏此卡并把目标怪兽加入手牌
function c4538826.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查此卡和目标怪兽是否仍然存在于游戏中
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义特殊召唤所需满足的墓地怪兽过滤条件：必须是光属性或暗属性且能除外
function c4538826.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件：手牌或额外卡组中是否有足够的召唤位置，并且墓地是否有符合条件的光暗属性怪兽
function c4538826.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家墓地中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c4538826.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判断是否在手牌位置且场上存在召唤位置
	return ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or
		-- 判断是否在额外卡组位置且有足够特殊召唤区域
		(c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		-- 检查墓地中的怪兽是否包含光属性和暗属性各一只
		and g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 设置特殊召唤的目标选择逻辑：选择两张符合条件的墓地怪兽
function c4538826.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c4538826.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的墓地怪兽中选择两张光属性和暗属性各一张
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作：将选中的怪兽除外
function c4538826.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 支付一半基本分作为此效果的发动费用
function c4538826.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义场上的卡过滤条件：不在怪兽区域或在怪兽区域但序号小于5
function c4538826.gyfilter(c)
	return not c:IsLocation(LOCATION_MZONE) or c:GetSequence()<5
end
-- 定义墓地卡过滤条件：在墓地且属于指定玩家
function c4538826.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 设置伤害效果的目标选择逻辑：选择场上所有卡并确定伤害值
function c4538826.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上的所有卡
	local g=Duel.GetMatchingGroup(c4538826.gyfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 获取对方场上的所有卡
	local og=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 and og:GetCount()>0 end
	local oc=og:GetCount()
	g:Merge(og)
	-- 设置操作信息：将场上所有卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,oc*300)
end
-- 执行伤害效果的操作：将场上卡送去墓地并计算伤害
function c4538826.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上的所有卡
	local g=Duel.GetMatchingGroup(c4538826.gyfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 检查是否有场上的卡需要送去墓地
	if g:GetCount()==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	-- 获取实际被送去墓地的卡数量
	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if oc==0 then return end
	-- 计算被送去对方墓地的卡数量
	local dc=Duel.GetOperatedGroup():FilterCount(c4538826.sgfilter,nil,1-tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择最多与送去墓地数量相等的对方场上的卡
	local og=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,oc,nil)
	-- 将选中的卡送去墓地
	if Duel.SendtoGrave(og,REASON_EFFECT)>0 then
		-- 更新被送去对方墓地的卡数量
		dc=dc+Duel.GetOperatedGroup():FilterCount(c4538826.sgfilter,nil,1-tp)
		if dc==0 then return end
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 给与对方相应数量×300的伤害
		Duel.Damage(1-tp,dc*300,REASON_EFFECT)
	end
end
-- 设置特殊召唤成功后的效果：此卡离开场时回到卡组最下面
function c4538826.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置此卡离开场时回到卡组最下面的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e1)
end
