--A・O・J アンノウン・クラッシャー
-- 效果：
-- 这张卡和光属性怪兽进行战斗时，把那只怪兽从游戏中除外。
function c22371016.initial_effect(c)
	-- 这张卡和光属性怪兽进行战斗时，把那只怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22371016,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c22371016.rmtg)
	e1:SetOperation(c22371016.rmop)
	c:RegisterEffect(e1)
end
-- 伤害计算后，判定本次战斗对象：若这张卡是攻击怪兽则取攻击目标，否则取攻击怪兽；将战斗对象记录到LabelObject并确认其为光属性，满足条件则登记除外操作信息。
function c22371016.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取本次战斗的攻击怪兽。
		local a=Duel.GetAttacker()
		-- 若攻击怪兽是这张卡自身，则将战斗对象改为其攻击目标（即对方怪兽）。
		if a==c then a=Duel.GetAttackTarget() end
		e:SetLabelObject(a)
		return a and a:IsAttribute(ATTRIBUTE_LIGHT)
	end
	-- 设置效果处理时，将LabelObject中记录的1只光属性怪兽除外的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 效果处理时，检查记录的战斗对象是否仍与本次战斗关联（未离场导致关系重置），若是则将其除外。
function c22371016.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 将那只战斗对象怪兽以表侧表示从游戏中除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
