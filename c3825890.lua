--墓守の大神官
-- 效果：
-- 这张卡可以把1只名字带有「守墓」的怪兽解放作召唤。这张卡的攻击力上升自己墓地存在的名字带有「守墓」的怪兽数量×200的数值。场上表侧表示存在的这张卡被破坏的场合，可以作为代替从手卡把1只名字带有「守墓」的怪兽丢弃。
function c3825890.initial_effect(c)
	-- 这张卡可以把1只名字带有「守墓」的怪兽解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3825890,0))  --"使用一只名字带有「守墓」的怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c3825890.otcon)
	e1:SetOperation(c3825890.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地存在的名字带有「守墓」的怪兽数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c3825890.atkval)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡被破坏的场合，可以作为代替从手卡把1只名字带有「守墓」的怪兽丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c3825890.desreptg)
	c:RegisterEffect(e3)
end
-- 过滤可作为解放召唤祭品的怪兽：必须为名字带有「守墓」的怪兽，且为我方控制或表侧表示。
function c3825890.otfilter(c,tp)
	return c:IsSetCard(0x2e) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤规则效果的发动条件：这张卡等级不低于7，需要解放1只怪兽，且场上存在满足条件的「守墓」怪兽可作为祭品。
function c3825890.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上满足解放条件（名字带有「守墓」且为我方控制或表侧表示）的怪兽集合，作为可选祭品。
	local mg=Duel.GetMatchingGroup(c3825890.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定是否满足上级召唤手续：这张卡等级在7以上，所需祭品数不超过1，并且存在1只可解放的「守墓」怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 召唤规则效果处理：从可选祭品中选择1只「守墓」怪兽，将其设定为素材并解放，以完成上级召唤。
function c3825890.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上满足解放条件（名字带有「守墓」且为我方控制或表侧表示）的怪兽集合，作为可选祭品。
	local mg=Duel.GetMatchingGroup(c3825890.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从符合条件的「守墓」怪兽中选择1只作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品怪兽解放，解放原因记为上级召唤的素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤条件：卡名含有「守墓」且为怪兽卡，用于检查墓地或手牌中可被利用的「守墓」怪兽。
function c3825890.filter(c)
	return c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER)
end
-- 攻击力上升值的计算函数：根据自己墓地存在的「守墓」怪兽数量决定攻击力上升数值。
function c3825890.atkval(e,c)
	-- 返回自己墓地中名字带有「守墓」的怪兽数量乘以200，作为这张卡的攻击力上升值。
	return Duel.GetMatchingGroupCount(c3825890.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*200
end
-- 代替破坏效果的发动条件判定：这张卡将要被破坏，且不是由代替破坏的效果触发，同时手牌中存在「守墓」怪兽可以丢弃。
function c3825890.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 追加条件：手牌中存在至少1只名字带有「守墓」的怪兽可供丢弃。
		and Duel.IsExistingMatchingCard(c3825890.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 询问玩家是否发动代替破坏效果，选择丢弃手牌中的「守墓」怪兽来取代这张卡的破坏。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 给出选择提示，要求玩家从手牌中选择要丢弃的卡牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 玩家从手牌中选择1只名字带有「守墓」的怪兽，作为代替破坏的丢弃代价。
		local g=Duel.SelectMatchingCard(tp,c3825890.filter,tp,LOCATION_HAND,0,1,1,nil)
		-- 将所选的「守墓」怪兽送入墓地，以此作为这张卡被破坏的代替处理。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
