--禁断の異本
-- 效果：
-- ①：宣言1个怪兽卡的种类（融合·同调·超量）才能发动。宣言的种类的怪兽在场上有2只以上表侧表示存在的场合，双方玩家必须把场上的那个种类的怪兽全部送去墓地。
function c3211439.initial_effect(c)
	-- ①：宣言1个怪兽卡的种类（融合·同调·超量）才能发动。宣言的种类的怪兽在场上有2只以上表侧表示存在的场合，双方玩家必须把场上的那个种类的怪兽全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3211439.target)
	e1:SetOperation(c3211439.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：筛选出场上表侧表示且属于指定怪兽种类（融合/同调/超量）的怪兽。
function c3211439.filter(c,tpe)
	return c:IsFaceup() and c:IsType(tpe)
end
-- 发动时的目标处理：先检查场上是否存在至少2只表侧表示的融合/同调/超量怪兽（满足其一即可发动），再让发动者从可选的种类中宣言1个，并将宣言种类存入效果标签。
function c3211439.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少2只表侧表示的融合怪兽，作为可宣言“融合”的发动条件之一。
	local b1=Duel.IsExistingMatchingCard(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_FUSION)
	-- 检查场上是否存在至少2只表侧表示的同调怪兽，作为可宣言“同调”的发动条件之一。
	local b2=Duel.IsExistingMatchingCard(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_SYNCHRO)
	-- 检查场上是否存在至少2只表侧表示的超量怪兽，作为可宣言“超量”的发动条件之一。
	local b3=Duel.IsExistingMatchingCard(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_XYZ)
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(3211439,0)  --"融合"
		opval[off-1]=TYPE_FUSION
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(3211439,1)  --"同调"
		opval[off-1]=TYPE_SYNCHRO
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(3211439,2)  --"超量"
		opval[off-1]=TYPE_XYZ
		off=off+1
	end
	-- 向玩家弹出“请选择一个种类”的提示，用于选择宣言的怪兽种类。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家在可用宣言的种类列表中作出选择，返回所选选项的序号（从0开始）。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
end
-- 效果处理：根据宣言的种类获取场上所有表侧表示且为该种类的怪兽，若数量大于1则将这些怪兽全部送去墓地，对应“双方玩家必须把场上的那个种类的怪兽全部送去墓地”。
function c3211439.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示且属于所宣言种类的怪兽（不取对象，处理时才确定具体卡）。
	local g=Duel.GetMatchingGroup(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	if g:GetCount()>1 then
		-- 将符合条件的怪兽以规则理由全部送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
