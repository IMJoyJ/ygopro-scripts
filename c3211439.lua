--禁断の異本
-- 效果：
-- ①：宣言1个怪兽卡的种类（融合·同调·超量）才能发动。宣言的种类的怪兽在场上有2只以上表侧表示存在的场合，双方玩家必须把场上的那个种类的怪兽全部送去墓地。
function c3211439.initial_effect(c)
	-- 效果原文内容：①：宣言1个怪兽卡的种类（融合·同调·超量）才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3211439.target)
	e1:SetOperation(c3211439.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义一个过滤函数，用于检查目标怪兽是否为表侧表示且属于指定类型
function c3211439.filter(c,tpe)
	return c:IsFaceup() and c:IsType(tpe)
end
-- 效果作用：判断是否满足发动条件，即己方场上有2只以上对应类型的表侧表示怪兽，若满足则允许发动
function c3211439.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查己方场上有无2只以上表侧表示的融合怪兽
	local b1=Duel.IsExistingMatchingCard(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_FUSION)
	-- 效果作用：检查己方场上有无2只以上表侧表示的同调怪兽
	local b2=Duel.IsExistingMatchingCard(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,TYPE_SYNCHRO)
	-- 效果作用：检查己方场上有无2只以上表侧表示的超量怪兽
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
	-- 效果作用：提示玩家选择一个怪兽种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 效果作用：让玩家从可选的种类中选择一个
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
end
-- 效果原文内容：宣言的种类的怪兽在场上有2只以上表侧表示存在的场合，双方玩家必须把场上的那个种类的怪兽全部送去墓地。
function c3211439.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c3211439.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	if g:GetCount()>1 then
		-- 效果作用：将符合条件的怪兽全部送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
