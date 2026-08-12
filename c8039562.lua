--ドラグニティ－ファルシオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·墓地的这张卡除外，以自己场上1只「龙骑兵团」怪兽为对象才能发动。从自己的卡组·墓地把1只龙族「龙骑兵团」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
-- ②：把给「龙骑兵团」怪兽装备的这张卡送去墓地，以对方场上1张表侧表示卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的装备效果和②的除外效果
function s.initial_effect(c)
	-- ①：把手卡·墓地的这张卡除外，以自己场上1只「龙骑兵团」怪兽为对象才能发动。从自己的卡组·墓地把1只龙族「龙骑兵团」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	-- 检查并执行发动代价：将手卡·墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：把给「龙骑兵团」怪兽装备的这张卡送去墓地，以对方场上1张表侧表示卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「龙骑兵团」怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 过滤条件：卡组·墓地中可以作为装备卡装备的龙族「龙骑兵团」怪兽
function s.eqfilter(c,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_MONSTER)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动准备与合法性检测
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为对象的「龙骑兵团」怪兽
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己卡组或墓地是否存在可以装备的龙族「龙骑兵团」怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要装备的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「龙骑兵团」怪兽作为效果对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：从卡组或墓地将1张卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的效果处理（将卡组·墓地的龙族「龙骑兵团」怪兽装备给对象怪兽）
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍在场上表侧表示存在，且自己魔陷区有空位
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组或墓地选择1张满足条件的龙族「龙骑兵团」怪兽（适用王家之谷的否定效果）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			-- 将选择的怪兽作为装备卡装备给对象怪兽，若失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 当作装备魔法卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 限制装备卡只能装备给作为对象的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果的发动代价检测与执行（检查自身是否装备给「龙骑兵团」怪兽，并将自身送去墓地）
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local et=e:GetHandler():GetEquipTarget()
	if chk==0 then return et~=nil and et:IsSetCard(0x29) and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为装备卡的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：对方场上表侧表示且可以被除外的卡
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- ②效果的发动准备与合法性检测
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的效果处理（将作为对象的卡除外）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为除外对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将作为对象的卡以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
