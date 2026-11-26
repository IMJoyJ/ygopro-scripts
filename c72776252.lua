--氷水大剣現
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上或者对方墓地有怪兽存在，自己场上有水属性怪兽存在的场合才能发动。从卡组选1只「冰水」怪兽送去墓地或特殊召唤。
-- ②：自己场上的表侧表示的「冰水」怪兽以破坏以外的方法因对方从场上离开的场合，把墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 初始化「冰水大剑现」(72776252)：注册①条件满足时从卡组将1只「冰水」怪兽堆墓或特召的发动效果，以及②己方「冰水」怪兽非破坏因对方离场时除外墓地自身并除外对方1卡的效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方场上或者对方墓地有怪兽存在，自己场上有水属性怪兽存在的场合才能发动。从卡组选1只「冰水」怪兽送去墓地或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
	-- 设置效果②的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示的水属性怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的Condition函数：检查对方怪兽区或墓地有怪兽存在，且己方怪兽区有表侧水属性怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方怪兽区存在卡片或对方墓地存在怪兽卡
	return (Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 or Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER))
		-- 且确认己方怪兽区存在至少1只表侧表示的水属性怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：筛选卡组中「冰水」(0x16c)字段的怪兽，要求可送去墓地或在有空位时可特殊召唤
function s.filter(c,e,tp)
	return c:IsSetCard(0x16c) and c:IsType(TYPE_MONSTER)
		-- 检查该「冰水」怪兽是否可以送去墓地，或在己方怪兽区有空位时可以被特殊召唤
		and (c:IsAbleToGrave() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果①的Target函数：检测己方卡组中存在可送墓或特殊召唤的「冰水」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1只满足条件的「冰水」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果①的Operation函数：从卡组选1只「冰水」怪兽，根据可执行操作动态生成“送去墓地”或“特殊召唤”选项并执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要操作的「冰水」怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsAbleToGrave()
		-- 检查己方怪兽区有空位且选中的「冰水」怪兽可被特殊召唤（用于判定是否提供特召选项）
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
		-- 让己方玩家从有效操作（送去墓地或特殊召唤）中选择一项并转换为1-based索引
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			-- 当选择送去墓地(sel==0)时，以效果将选中的「冰水」怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif sel==1 then
			-- 当选择特殊召唤(sel==1)时，将选中的「冰水」怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：检查离场卡片是否原本为己方怪兽区表侧表示的「冰水」(0x16c)怪兽，且因对方操作以破坏以外的方法离开场上
function s.egfilter(c,tp)
	return not c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x16c) and c:GetReasonPlayer()==1-tp
end
-- 效果②的Condition函数：检查本次离场事件eg中是否存在符合条件的己方「冰水」怪兽
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end
-- 效果②的Target函数：检测对方场上存在可除外的卡，取其中1张为对象并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动检测时确认对方场上存在至少1张可以作为对象并被除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向己方玩家发送选择要除外的对方场上卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1张可除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置将所选对象卡除外（离开场上）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 效果②的Operation函数：确认对方对象卡仍与当前效果关联后，将其以表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时指定为对象的对方场上卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果将选中的对方场上对象卡表侧除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
