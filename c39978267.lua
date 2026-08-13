--サイバー・レイダー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤时，从下列效果中选择1项发动：
-- ●选择场上1张装备在怪兽身上的装备卡并将其破坏。
-- ●选择场上1张装备在怪兽身上的装备卡并将其装备在这张卡身上。
function c39978267.initial_effect(c)
	-- 对应效果原文：“这张卡召唤·反转召唤·特殊召唤时，从下列效果中选择1项发动：”；本行将这一诱发效果注册到卡片，并通过e1、e2、e3分别处理召唤、特殊召唤、反转召唤成功时点。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39978267,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c39978267.target)
	e1:SetOperation(c39978267.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 装备卡状态过滤：若该卡当前装备在怪兽身上（GetEquipTarget()非nil），或为表侧表示的装备卡，则满足“场上1张装备在怪兽身上的装备卡”的选取条件。
function c39978267.desfilter(c)
	return c:GetEquipTarget() or c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 装备可行性过滤：该卡必须是装备卡，且能通过CheckEquipTarget正确装备给电子袭击者，用于选择“装备在这张卡身上”的对象。
function c39978267.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 连锁阶段的对象合法校验：若已选择破坏分支，则对象须位于魔陷区且满足desfilter；若选择装备分支，则对象须位于魔陷区且满足eqfilter（可作为此卡装备）。
function c39978267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then return chkc:IsLocation(LOCATION_SZONE) and c39978267.desfilter(chkc)
		else return chkc:IsLocation(LOCATION_SZONE) and c39978267.eqfilter(chkc,e:GetHandler()) end
	end
	if chk==0 then return true end
	local sel=0
	-- 检查场上是否存在可被①效果选为对象的装备卡，若存在则标记破坏选项可用（sel+1）。
	if Duel.IsExistingMatchingCard(c39978267.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) then sel=sel+1 end
	-- 检查场上是否存在可装备给此卡的装备卡，若存在则标记装备选项可用（sel+2）。
	if Duel.IsExistingMatchingCard(c39978267.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) then sel=sel+2 end
	if sel==3 then
		-- 向玩家发出选项选择提示（缓存“选择效果发动”的提示信息），准备让玩家在两项效果中择一发动。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39978267,0))  --"选择效果发动"
		-- 通过Duel.SelectOption让玩家选择“装备卡破坏”或“装备卡装备在这张卡身上”，返回值0/1加1得到sel=1/2，对应两种分支。
		sel=Duel.SelectOption(tp,aux.Stringid(39978267,1),aux.Stringid(39978267,2))+1  --"装备卡破坏/装备卡装备在这张卡身上"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 发送“请选择要破坏的卡”的选择提示，指导玩家选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择1张场上符合desfilter的装备卡作为破坏对象（取对象），并自动将对象与当前连锁关联。
		local g=Duel.SelectTarget(tp,c39978267.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		-- 登记操作信息：本次连锁将破坏刚才选择的对象，分类为CATEGORY_DESTROY，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif sel==2 then
		e:SetCategory(0)
		-- 发送“请选择要装备的卡”的选择提示，指导玩家选择装备对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择1张场上符合eqfilter且能装备给电子袭击者的装备卡作为对象（取对象），e:GetHandler()即电子袭击者。
		local g=Duel.SelectTarget(tp,c39978267.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
	end
end
-- 效果处理：根据选项sel执行对应效果；sel=0直接结束，sel=1且对象仍相关则将其破坏，sel=2且对象仍相关则将其装备给电子袭击者。
function c39978267.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then return end
	-- 获取当前连锁处理的对象卡（之前发动时选择的目标）。
	local tc=Duel.GetFirstTarget()
	if sel==1 then
		if tc and tc:IsRelateToEffect(e) then
			-- 以效果原因（REASON_EFFECT）破坏对象装备卡。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		local c=e:GetHandler()
		if tc and tc:IsRelateToEffect(e) then
			-- 将对象装备卡装备给电子袭击者，使其成为该卡的装备卡。
			Duel.Equip(tp,tc,c)
		end
	end
end
