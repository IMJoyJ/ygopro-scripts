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
-- 设置该卡阶级数值为0，配合规则上视为1阶使用的特殊处理。
aux.xyz_number[43490025]=0
-- 超量召唤素材过滤：素材必须是超量怪兽且不属于「No.」系列，满足『「No.」怪兽以外的相同阶级的超量怪兽×2』的素材条件。
function c43490025.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and not c:IsSetCard(0x48)
end
-- 检查超量素材的阶级种类数是否为1，即所有素材阶级相同，以满足『相同阶级的超量怪兽×2』的召唤要求。
function c43490025.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 重叠召唤的基底判定：对象是自己场上表侧表示的「希望皇 霍普」怪兽或「未来No.0 未来皇 霍普」（卡号65305468）。
function c43490025.ovfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x107f) or c:IsCode(65305468))
end
-- 攻击力加成的计数对象过滤：墓地中的「No.」超量怪兽（同时满足超量怪兽类型和「No.」系列）。
function c43490025.atkfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 计算攻击力上升值：统计以这张卡控制者为视角的双方墓地中的「No.」超量怪兽数量，乘以500。
function c43490025.atkval(e,c)
	-- 获取双方墓地中满足atkfilter的「No.」超量怪兽数量并乘以500，作为攻击力上升值返回。
	return Duel.GetMatchingGroupCount(c43490025.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*500
end
-- ③效果发动条件：当前回合玩家能够进入战斗阶段。
function c43490025.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能够进入战斗阶段，作为发动③效果的前提。
	return Duel.IsAbleToEnterBP()
end
-- 消耗代价处理：从这张卡上取除1个超量素材（先检查可否取除，再实际取除）。
function c43490025.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动目标检查：确认这张卡还没有获得额外攻击次数效果（EFFECT_EXTRA_ATTACK计数为0），防止重复赋予。
function c43490025.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 效果处理：若这张卡仍与发动效果关联，则赋予它1次额外攻击次数，效果不可无效，持续到结束阶段或标准重置时机。
function c43490025.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
