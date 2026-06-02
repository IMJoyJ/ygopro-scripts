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
	-- 启用灵摆怪兽属性及灵摆卡发动效果
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
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e5:SetValue(LOCATION_DECKBOT)
	e5:SetCondition(c4538826.rmcon)
	c:RegisterEffect(e5)
end
-- 灵摆效果①的发动代价（支付1000基本分）
function c4538826.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤满足条件的除外的龙族怪兽（表侧表示且能加入手卡）
function c4538826.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 灵摆效果①的靶向与发动检测（选择1只除外的龙族怪兽为对象）
function c4538826.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c4538826.thfilter(chkc) end
	-- 检查是否存在可以成为对象的除外的龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c4538826.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只龙族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c4538826.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置破坏自身这张灵摆卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置把目标怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果①的效果处理（破坏这张卡并将对象加入手卡）
function c4538826.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查此卡是否与效果相关并成功破坏，若成功破坏且对象卡亦相关则继续
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤墓地中用于特殊召唤的光属性或暗属性怪兽
function c4538826.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规程的发动条件
function c4538826.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中满足除外条件的卡片组
	local g=Duel.GetMatchingGroup(c4538826.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查从手卡特殊召唤时自己场上是否有空余 of 怪兽区域
	return ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or
		-- 从额外卡组特殊召唤时，检查额外怪兽区域或可用的主怪兽区域是否有空格
		(c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		-- 且检查墓地中是否存在光属性和暗属性怪兽各1只
		and g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 特殊召唤规程的卡片选择阶段
function c4538826.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中符合除外条件的卡片
	local g=Duel.GetMatchingGroup(c4538826.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择光属性和暗属性的怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规程的效果执行（将所选卡片除外）
function c4538826.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的2只怪兽表侧表示除外以进行特殊召唤
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 怪兽效果①的发动代价（支付一半基本分）
function c4538826.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半的基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤额外怪兽区域以外的自己场上的卡
function c4538826.gyfilter(c)
	return not c:IsLocation(LOCATION_MZONE) or c:GetSequence()<5
end
-- 检查卡片是否在对应玩家墓地中
function c4538826.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 怪兽效果①的靶向与发动检测（确认场上有卡并设置操作信息）
function c4538826.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取额外怪兽区域以外的自己场上的所有卡
	local g=Duel.GetMatchingGroup(c4538826.gyfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 获取对方场上的所有卡
	local og=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 and og:GetCount()>0 end
	local oc=og:GetCount()
	g:Merge(og)
	-- 设置将自己场上的卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置给与对方基本分伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,oc*300)
end
-- 怪兽效果①的效果处理（送去墓地并给予对方伤害）
function c4538826.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外怪兽区域以外的自己场上的所有卡
	local g=Duel.GetMatchingGroup(c4538826.gyfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 如果自己场上可操作的卡数量为0或送去墓地失败则处理终止
	if g:GetCount()==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	-- 计算在此操作中实际被送去自己墓地的卡片数量
	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if oc==0 then return end
	-- 计算已被送去对方墓地的卡片数量
	local dc=Duel.GetOperatedGroup():FilterCount(c4538826.sgfilter,nil,1-tp)
	-- 提示玩家选择要送去墓地的对方场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择最多有自己送去墓地的数量的对方场上的卡
	local og=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,oc,nil)
	-- 将选择的对方场上的卡送去墓地，并检查是否成功
	if Duel.SendtoGrave(og,REASON_EFFECT)>0 then
		-- 累计对方场上因该效果被送去墓地的卡的数量
		dc=dc+Duel.GetOperatedGroup():FilterCount(c4538826.sgfilter,nil,1-tp)
		if dc==0 then return end
		-- 中断效果，使伤害与送去墓地不视为同时处理
		Duel.BreakEffect()
		-- 给与对方送去对方墓地的数量×300伤害
		Duel.Damage(1-tp,dc*300,REASON_EFFECT)
	end
end
-- 特殊召唤的此卡离场重定向的条件判断（必须是特殊召唤且表侧表示）
function c4538826.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup()
end
