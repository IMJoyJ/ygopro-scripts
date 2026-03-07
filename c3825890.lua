--墓守の大神官
-- 效果：
-- 这张卡可以把1只名字带有「守墓」的怪兽解放作召唤。这张卡的攻击力上升自己墓地存在的名字带有「守墓」的怪兽数量×200的数值。场上表侧表示存在的这张卡被破坏的场合，可以作为代替从手卡把1只名字带有「守墓」的怪兽丢弃。
function c3825890.initial_effect(c)
	-- 效果原文：这张卡可以把1只名字带有「守墓」的怪兽解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3825890,0))  --"使用一只名字带有「守墓」的怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c3825890.otcon)
	e1:SetOperation(c3825890.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡的攻击力上升自己墓地存在的名字带有「守墓」的怪兽数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c3825890.atkval)
	c:RegisterEffect(e2)
	-- 效果原文：场上表侧表示存在的这张卡被破坏的场合，可以作为代替从手卡把1只名字带有「守墓」的怪兽丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c3825890.desreptg)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回名字带有「守墓」且在场上或由玩家控制的怪兽
function c3825890.otfilter(c,tp)
	return c:IsSetCard(0x2e) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断召唤条件：满足等级7以上、最少祭品为1、且场上存在满足条件的祭品
function c3825890.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的场上怪兽数组
	local mg=Duel.GetMatchingGroup(c3825890.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回是否满足召唤条件
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 处理召唤操作：选择并解放1只满足条件的怪兽
function c3825890.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足条件的场上怪兽数组
	local mg=Duel.GetMatchingGroup(c3825890.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只满足条件的怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的怪兽解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：返回名字带有「守墓」的怪兽
function c3825890.filter(c)
	return c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力增加量：根据墓地中的「守墓」怪兽数量乘以200
function c3825890.atkval(e,c)
	-- 返回墓地中「守墓」怪兽数量乘以200作为攻击力增加量
	return Duel.GetMatchingGroupCount(c3825890.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*200
end
-- 判断是否可以发动代替破坏效果：检查手牌中是否存在「守墓」怪兽
function c3825890.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 检查手牌中是否存在至少1张「守墓」怪兽
		and Duel.IsExistingMatchingCard(c3825890.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择1张手牌中的「守墓」怪兽
		local g=Duel.SelectMatchingCard(tp,c3825890.filter,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的怪兽丢入墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
