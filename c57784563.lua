--闇魔界の戦士長 ダークソード
-- 效果：
-- 1回合1次，把自己墓地1只暗属性怪兽从游戏中除外，选择对方场上1只光属性·4星以下的怪兽才能发动。选择的怪兽当作装备卡使用只有1只给这张卡装备。此外，场上的这张卡被破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
function c57784563.initial_effect(c)
	-- 1回合1次，把自己墓地1只暗属性怪兽从游戏中除外，选择对方场上1只光属性·4星以下的怪兽才能发动。选择的怪兽当作装备卡使用只有1只给这张卡装备。此外，场上的这张卡被破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57784563,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c57784563.eqcon)
	e1:SetCost(c57784563.eqcost)
	e1:SetTarget(c57784563.eqtg)
	e1:SetOperation(c57784563.eqop)
	c:RegisterEffect(e1)
end
-- 检查这张卡当前是否未装备由自身效果装备的怪兽（限制只能装备1只）
function c57784563.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(57784563)==0
end
-- 过滤条件：自己墓地的暗属性且可以作为代价除外的怪兽
function c57784563.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：把自己墓地1只暗属性怪兽除外
function c57784563.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57784563.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c57784563.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：对方场上表侧表示、4星以下的光属性且可以转移控制权的怪兽
function c57784563.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToChangeControler()
end
-- 效果目标：选择对方场上1只光属性·4星以下的怪兽为对象
function c57784563.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c57784563.filter(chkc) end
	-- 检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且对方场上存在至少1只满足条件的光属性·4星以下的怪兽
		and Duel.IsExistingTarget(c57784563.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只满足条件的光属性·4星以下的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57784563.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制：该装备卡只能装备于这张卡
function c57784563.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将选择的怪兽作为装备卡装备给这张卡，并添加代破效果
function c57784563.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(57784563,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 选择的怪兽当作装备卡使用只有1只给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c57784563.eqlimit)
		tc:RegisterEffect(e1)
		-- 作为代替把这张卡的效果装备的怪兽破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end
