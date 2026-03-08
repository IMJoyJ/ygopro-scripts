--FNo.0 未来皇ホープ－フューチャー・スラッシュ
-- 效果：
-- 「No.」怪兽以外的相同阶级的超量怪兽×2
-- 规则上，这张卡的阶级当作1阶使用。这张卡也能在自己场上的「希望皇 霍普」怪兽或者「未来No.0 未来皇 霍普」上面重叠来超量召唤。
-- ①：这张卡的攻击力上升双方墓地的「No.」超量怪兽数量×500。
-- ②：这张卡不会被战斗破坏。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c43490025.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c43490025.mfilter,c43490025.xyzcheck,2,2,c43490025.ovfilter,aux.Stringid(43490025,1))  --"是否在霍普怪兽上重叠来超量召唤？"
	-- ①：这张卡的攻击力上升双方墓地的「No.」超量怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c43490025.atkval)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(43490025,0))  --"2次攻击"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c43490025.atkcon)
	e4:SetCost(c43490025.atkcost)
	e4:SetTarget(c43490025.atktg)
	e4:SetOperation(c43490025.atkop)
	c:RegisterEffect(e4)
end
-- 设置该卡的超量阶级为0
aux.xyz_number[43490025]=0
-- 过滤满足条件的怪兽：超量怪兽且不属于「No.」系列
function c43490025.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and not c:IsSetCard(0x48)
end
-- 检查叠放的怪兽数组中是否所有怪兽的阶级相同
function c43490025.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 过滤满足条件的怪兽：表侧表示且属于「希望皇 霍普」系列或卡号为65305468的怪兽
function c43490025.ovfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x107f) or c:IsCode(65305468))
end
-- 过滤满足条件的怪兽：超量怪兽且属于「No.」系列
function c43490025.atkfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 计算双方墓地中「No.」超量怪兽数量并乘以500作为攻击力加成
function c43490025.atkval(e,c)
	-- 检索双方墓地中满足条件的「No.」超量怪兽数量
	return Duel.GetMatchingGroupCount(c43490025.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*500
end
-- 判断是否可以进入战斗阶段
function c43490025.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 支付效果代价：从自身场上取除1个超量素材
function c43490025.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断该卡是否未受到额外攻击效果影响
function c43490025.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 为该卡添加1个额外攻击效果，使其在本回合可进行2次攻击
function c43490025.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 为该卡添加1个额外攻击效果，使其在本回合可进行2次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
