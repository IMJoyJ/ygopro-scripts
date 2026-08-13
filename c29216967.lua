--ギミック・パペット－シザー・アーム
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只「机关傀儡」怪兽送去墓地。
function c29216967.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只「机关傀儡」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29216967,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c29216967.target)
	e1:SetOperation(c29216967.operation)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选择卡组中满足“怪兽卡、卡名含‘机关傀儡’字段、且可以送去墓地”的卡片。
function c29216967.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1083) and c:IsAbleToGrave()
end
-- 效果发动时的目标处理：先判断是否满足发动条件，再登记将1张卡送去墓地的操作信息。
function c29216967.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动合法性检查，则判定卡组中是否存在至少1只符合条件的「机关傀儡」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c29216967.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：将把1张卡从卡组送去墓地，用于连锁时点及相关卡片的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：从卡组选出1只符合条件的「机关傀儡」怪兽并送去墓地。
function c29216967.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要送去墓地的卡”的提示，并准备接收选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张满足tgfilter过滤条件的「机关傀儡」怪兽。
	local g=Duel.SelectMatchingCard(tp,c29216967.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
