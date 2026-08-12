--E・HERO テンペスター
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 电光侠」＋「元素英雄 水泡侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：把自己场上1张其他卡送去墓地，以自己场上1只怪兽为对象才能发动。这张卡表侧表示存在期间，那只怪兽不会被战斗破坏。
function c83121692.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「元素英雄 羽翼侠」＋「元素英雄 电光侠」＋「元素英雄 水泡侠」为素材的融合召唤手续
	aux.AddFusionProcCode3(c,21844576,20721928,79979666,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制只能通过融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：把自己场上1张其他卡送去墓地，以自己场上1只怪兽为对象才能发动。这张卡表侧表示存在期间，那只怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83121692,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c83121692.cost)
	e1:SetTarget(c83121692.target)
	e1:SetOperation(c83121692.operation)
	c:RegisterEffect(e1)
end
c83121692.material_setcode=0x8
-- 效果①的代价处理函数：将自己场上1张其他卡送去墓地
function c83121692.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外、可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张除这张卡以外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：筛选未被此卡效果标记且不为此卡效果对象的怪兽
function c83121692.tgfilter(c,ec)
	return c:GetFlagEffect(83121692)==0 and not ec:IsHasCardTarget(c)
end
-- 效果①的对象选择与发动准备函数
function c83121692.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83121692.tgfilter(chkc,c) end
	-- 检查自己场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c83121692.tgfilter,tp,LOCATION_MZONE,0,1,nil,c) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,c83121692.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
end
-- 效果①的效果处理函数：使目标怪兽获得战斗破坏耐性，并建立与此卡的关联
function c83121692.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	if not tc:IsRelateToEffect(e) then return end
	if c==tc then
		tc:RegisterFlagEffect(83121692,RESET_EVENT+RESETS_STANDARD,0,0)
	else
		c:SetCardTarget(tc)
	end
	-- 这张卡表侧表示存在期间，那只怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c83121692.indcon)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
-- 战斗破坏耐性效果的维持条件：此卡在场上表侧表示存在（或目标怪兽自身被标记）
function c83121692.indcon(e)
	local c=e:GetHandler()
	local rc=e:GetOwner()
	if c==rc then
		return c:GetFlagEffect(83121692)~=0
	else
		return rc:IsHasCardTarget(c)
	end
end
