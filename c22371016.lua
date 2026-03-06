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
-- 检查战斗中的对方怪兽是否为光属性，用于确定是否发动效果
function c22371016.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取此次战斗的攻击怪兽
		local a=Duel.GetAttacker()
		-- 如果攻击怪兽是自己，则获取攻击目标怪兽
		if a==c then a=Duel.GetAttackTarget() end
		e:SetLabelObject(a)
		return a and a:IsAttribute(ATTRIBUTE_LIGHT)
	end
	-- 设置效果处理时要除外的怪兽为操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 将符合条件的怪兽从游戏中除外
function c22371016.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 以效果为原因，将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
