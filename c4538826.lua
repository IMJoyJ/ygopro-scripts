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
	-- 添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：支付1000基本分，以除外的1只自己的龙族怪兽为对象才能发动。这张卡破坏，那只怪兽加入手卡。
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
-- 灵摆效果发动代价：支付1000基本分
function c4538826.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤除外区表侧表示且能加入手卡的龙族怪兽
function c4538826.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果发动取对象与设置操作信息：破坏自身并将除外的怪兽加入手卡
function c4538826.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c4538826.thfilter(chkc) end
	-- 检查除外区是否存在满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c4538826.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只龙族怪兽作为对象
	local g=Duel.SelectTarget(tp,c4538826.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：将对象怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：这张卡破坏，选中的怪兽加入手卡
function c4538826.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 破坏自身成功且对象怪兽仍和效果有联系
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤墓地可以除外作为代价的光·暗属性怪兽
function c4538826.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续条件判断
function c4538826.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取墓地中满足条件的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c4538826.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 从手卡出场需主要怪兽区有空位
	return ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or
		-- 从额外卡组出场需额外怪兽区或连接区有空位
		(c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		-- 检查墓地是否存在光属性和暗属性怪兽各1只
		and g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 选择特殊召唤手续所需的除外素材
function c4538826.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取墓地中满足条件的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c4538826.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择光属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续处理：除外选中的素材
function c4538826.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的素材表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 怪兽效果发动代价：支付一半基本分
function c4538826.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤额外怪兽区域以外的自己场上的卡
function c4538826.gyfilter(c)
	return not c:IsLocation(LOCATION_MZONE) or c:GetSequence()<5
end
-- 过滤实际送去指定玩家墓地的卡
function c4538826.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 效果发动检查与设置操作信息：双方场上卡送去墓地并造成伤害
function c4538826.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取额外怪兽区域以外的自己场上的卡
	local g=Duel.GetMatchingGroup(c4538826.gyfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 获取对方场上的全部卡片
	local og=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 and og:GetCount()>0 end
	local oc=og:GetCount()
	g:Merge(og)
	-- 设置操作信息：将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,oc*300)
end
-- 效果处理：送去墓地并给与对方伤害
function c4538826.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外怪兽区域以外的自己场上的卡
	local g=Duel.GetMatchingGroup(c4538826.gyfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 将自己场上的卡全部送去墓地，若没有送去墓地则结束处理
	if g:GetCount()==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	-- 计算自己成功送去墓地的卡片数量
	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if oc==0 then return end
	-- 计算送去对方墓地的卡片数量（用于计算伤害）
	local dc=Duel.GetOperatedGroup():FilterCount(c4538826.sgfilter,nil,1-tp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选最多有送去墓地数量的对方场上的卡
	local og=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,oc,nil)
	-- 将选中的对方场上的卡送去墓地
	if Duel.SendtoGrave(og,REASON_EFFECT)>0 then
		-- 累计送去对方墓地的卡片数量
		dc=dc+Duel.GetOperatedGroup():FilterCount(c4538826.sgfilter,nil,1-tp)
		if dc==0 then return end
		-- 中断效果处理
		Duel.BreakEffect()
		-- 给与对方送去对方墓地的数量×300伤害
		Duel.Damage(1-tp,dc*300,REASON_EFFECT)
	end
end
-- 离场效果适用条件：特殊召唤且在怪兽区表侧表示存在
function c4538826.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
