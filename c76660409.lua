--ペンデュラム・バック
-- 效果：
-- ①：自己的灵摆区域有2张卡存在的场合，以持有用那些灵摆刻度可以灵摆召唤的等级的自己墓地2只怪兽为对象才能发动。那些怪兽加入手卡。
function c76660409.initial_effect(c)
	-- ①：自己的灵摆区域有2张卡存在的场合，以持有用那些灵摆刻度可以灵摆召唤的等级的自己墓地2只怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c76660409.condition)
	e1:SetTarget(c76660409.target)
	e1:SetOperation(c76660409.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查自己的灵摆区域是否有2张卡存在
function c76660409.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己左、右两个灵摆区域是否都存在卡片
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
-- 过滤条件：筛选出等级介于两个灵摆刻度之间且可以加入手牌的怪兽
function c76660409.filter(c,lsc,rsc)
	local lv=c:GetLevel()
	return lv>lsc and lv<rsc and c:IsAbleToHand()
end
-- 效果发动时的目标选择：获取灵摆刻度，确认并选择自己墓地2只符合等级条件的怪兽作为对象
function c76660409.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己左侧灵摆区域卡片的左灵摆刻度
	local lsc=Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale()
	-- 获取自己右侧灵摆区域卡片的右灵摆刻度
	local rsc=Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale()
	if lsc>rsc then lsc,rsc=rsc,lsc end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76660409.filter(chkc,lsc,rsc) end
	-- 在发动效果时，检查自己墓地是否存在2只符合等级条件且可以加入手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(c76660409.filter,tp,LOCATION_GRAVE,0,2,nil,lsc,rsc) end
	-- 向发动玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地2只符合等级条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c76660409.filter,tp,LOCATION_GRAVE,0,2,2,nil,lsc,rsc)
	-- 设置操作信息，表示该效果的处理为将选中的2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理：获取选中的对象，将其中仍符合条件的卡加入手牌
function c76660409.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍符合条件的对象怪兽加入持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
