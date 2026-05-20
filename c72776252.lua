--氷水大剣現
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上或者对方墓地有怪兽存在，自己场上有水属性怪兽存在的场合才能发动。从卡组选1只「冰水」怪兽送去墓地或特殊召唤。
-- ②：自己场上的表侧表示的「冰水」怪兽以破坏以外的方法因对方从场上离开的场合，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（魔法卡发动）和②效果（墓地诱发效果）
function s.initial_effect(c)
	-- ①：对方场上或者对方墓地有怪兽存在，自己场上有水属性怪兽存在的场合才能发动。从卡组选1只「冰水」怪兽送去墓地或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的「冰水」怪兽以破坏以外的方法因对方从场上离开的场合，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的水属性怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ①效果的发动条件：对方场上或对方墓地有怪兽存在，且自己场上有表侧表示的水属性怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上或对方墓地是否有怪兽存在
	return (Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 or Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER))
		-- 检查自己场上是否存在表侧表示的水属性怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可以送去墓地或特殊召唤的「冰水」怪兽
function s.filter(c,e,tp)
	return c:IsSetCard(0x16c) and c:IsType(TYPE_MONSTER)
		-- 检查该卡是否能送去墓地，或者在有可用怪兽区域时是否能特殊召唤
		and (c:IsAbleToGrave() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动准备，检查卡组中是否存在满足条件的「冰水」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「冰水」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ①效果的处理：从卡组选1只「冰水」怪兽，由玩家选择将其送去墓地或特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsAbleToGrave()
		-- 检查该怪兽是否满足特殊召唤的条件（有空怪兽位且可以特召）
		local b2=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false))
		local off=1
		local ops={}
		local opval={}
		if b1 then
			ops[off]=1191
			opval[off]=0
			off=off+1
		end
		if b2 then
			ops[off]=1152
			opval[off]=1
			off=off+1
		end
		-- 让玩家选择执行“送去墓地”还是“特殊召唤”
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			-- 将选中的怪兽因效果送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif sel==1 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：自己场上表侧表示的「冰水」怪兽因对方从场上离开（非破坏）
function s.egfilter(c,tp)
	return not c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x16c) and c:GetReasonPlayer()==1-tp
end
-- ②效果的发动条件：检查是否有符合条件的「冰水」怪兽因对方从场上离开
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end
-- ②效果的发动准备，确认并选择对方场上1张卡作为除外对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为除外选中的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ②效果的处理：将作为对象的对方场上的卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果选中的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
