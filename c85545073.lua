--デストーイ・シザー・ベアー
-- 效果：
-- 「锋利小鬼·剪刀」＋「毛绒动物·熊」
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽当作攻击力上升1000的装备卡使用给这张卡装备。
function c85545073.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「锋利小鬼·剪刀」和「毛绒动物·熊」为素材的融合召唤手续
	aux.AddFusionProcCode2(c,30068120,3841833,true,true)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽当作攻击力上升1000的装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85545073,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c85545073.eqcon)
	e1:SetTarget(c85545073.eqtg)
	e1:SetOperation(c85545073.eqop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否通过战斗破坏对方怪兽并送去墓地，以确定是否满足发动条件
function c85545073.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE)
end
-- 效果发动的靶向处理，将战斗破坏的怪兽设为效果处理对象，并声明涉及墓地卡片移动的操作信息
function c85545073.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	-- 将战斗破坏的怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示该效果包含将1张特定的墓地卡片移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果处理，将目标怪兽作为装备卡装备给此卡，并赋予其装备限制和攻击力上升1000的效果
function c85545073.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被设为效果处理对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽作为装备卡装备给此卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c85545073.eqlimit)
		tc:RegisterEffect(e1)
		-- 攻击力上升1000
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1000)
		tc:RegisterEffect(e2)
	end
end
-- 限制该装备卡只能装备给此卡（效果的持有者）
function c85545073.eqlimit(e,c)
	return e:GetOwner()==c
end
